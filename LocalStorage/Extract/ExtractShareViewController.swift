//
//  ExtractShareViewController.swift
//  Zip
//
//  Created by Günther Eberl on 27.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import Social


// Logger configuration.
let logExtractShareExtension = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "extract-action")


class ExtractShareViewController: SLComposeServiceViewController {

    var containedTypes: [String] = []
    var fileUrl: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logExtractShareExtension, type: .debug)
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                self.containedTypes = provider.registeredTypeIdentifiers
                
                // Search for "Uniform Type Identifiers Reference" for a full list of UTIs.

                // zip: "public.file-url" + "public.zip-archive"
                if provider.hasItemConformingToTypeIdentifier("public.zip-archive") {
                    provider.loadItem(forTypeIdentifier: "public.zip-archive",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }

                // 7z: "public.file-url" + "org.7-zip.7-zip-archive"
                if provider.hasItemConformingToTypeIdentifier("org.7-zip.7-zip-archive") {
                    provider.loadItem(forTypeIdentifier: "org.7-zip.7-zip-archive",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // tar: "public.file-url" + "public.tar-archive"
                if provider.hasItemConformingToTypeIdentifier("public.tar-archive") {
                    provider.loadItem(forTypeIdentifier: "public.tar-archive",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // other, unsupported files (eg. *.torrent): "public.file-url" + "public.data"
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var textFieldContent: String = ""
        if self.containedTypes.count > 0 {
            textFieldContent = "Contained file types: " + self.containedTypes.joined(separator: ", ") + "\n"
            textFieldContent += "Supported file types: public.zip-archive, org.7-zip.7-zip-archive, public.tar-archive"
        } else {
            textFieldContent = "No file types contained at all."
        }
        textFieldContent += "\n\n"
        if self.fileUrl == nil {
            textFieldContent += "Email <guenther@eberl.se> if you think you should be able to extract this item."
        } else {
            textFieldContent += "Opening archive in Local Storage ..."
        }
        self.textView.text = textFieldContent
        
        // Dismissing the keyboard doesn't work. Also not in viewDidLoad or the others.
        // self.view.endEditing(true)
        // self.textView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: logExtractShareExtension, type: .debug)
        super.viewWillAppear(animated)
        
        // Always change the title of the button on the top right, standard "Post".
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Extract"
        
        if self.fileUrl == nil {
            // File is not a zip file, disable top right button. Make self.didSelectPost() unreachable.
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func loadFile(coding: NSSecureCoding?, error: Error!) {
        os_log("loadFile", log: logExtractShareExtension, type: .debug)
        
        if error != nil {
            os_log("%@", log: logExtractShareExtension, type: .error, error.localizedDescription)
            return
        }
        
        if coding != nil {
            if let url = coding as? URL {
                self.fileUrl = self.copyToAppGroupFolder(srcUrl: url)
                if self.fileUrl != nil {
                    self.didSelectPost()  // File successfully copied over, hit the "Extract" button right away.
                }
            }
        }
    }
    
    func removeFileIfExist(path: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
                os_log("Removed file '%@'", log: logExtractShareExtension, type: .debug, path)
            } catch {
                os_log("%@", log: logExtractShareExtension, type: .error, error.localizedDescription)
            }
        }
    }
    
    func copyToAppGroupFolder(srcUrl: URL) -> URL? {
        let appGroupName: String = "group.se.eberl.localstorage"
        if let destDirUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) {
            
            let destUrl = destDirUrl.appendingPathComponent(srcUrl.lastPathComponent)
            removeFileIfExist(path: destUrl.path)  // copyItem doesn't overwrite but fail if file exists already.

            do {
                try FileManager.default.copyItem(at: srcUrl, to: destUrl)
                return destUrl
            } catch {
                os_log("Copying failed: %@", log: logExtractShareExtension, type: .error, error.localizedDescription)
            }
        }
        
        return nil
    }
    
    override func isContentValid() -> Bool {
        if self.fileUrl == nil {
            return false
        } else {
            return true
        }
    }
    
    @objc func openURL(_ url: URL) {
        // Function is needed for hack in self.openMainApp().
        return
    }
    
    func openMainApp() {
        os_log("openMainApp", log: logExtractShareExtension, type: .debug)
        
        // Hack to open main app from a share extension from https://stackoverflow.com/a/28037297/8137043
        // This may break in any new version on iOS.

        let selector = #selector(openURL(_:))

        var responder: UIResponder? = self as UIResponder
        while responder != nil {
            if responder!.responds(to: selector) && responder != self {
                responder!.perform(selector,
                                   with: URL(string: "localstorage://actionextension?extract=" + self.fileUrl!.path)!)
                return
            }
            responder = responder?.next
        }
    }
    
    override func configurationItems() -> [Any]! {
        if self.fileUrl == nil {
            let errorItem = SLComposeSheetConfigurationItem()!
            errorItem.title = "Error"
            errorItem.value = "File can't be extracted"
            return [errorItem]
        } else {
            return []
        }
    }

    override func didSelectPost() {
        os_log("didSelectPost", log: logExtractShareExtension, type: .debug)
        self.openMainApp()
        super.didSelectPost()
    }

}
