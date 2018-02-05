//
//  ActionViewController.swift
//  Hash
//
//  Created by Günther Eberl on 04.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import MobileCoreServices
import os.log
import CommonCryptoModule


// Logger configuration.
let logActionExtension = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "action")


extension Data {
    public func md5() -> Data {
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_MD5(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
}


class HashActionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var settingsTableView: UITableView!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBAction func onCalculateButton(_ sender: UIButton) { self.hashFile() }
    
    @IBOutlet weak var digestTextField: UITextField!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBAction func onCopyButton(_ sender: UIButton) { self.copyHash() }
    
    var fileData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
               // Search for "Uniform Type Identifiers Reference" for a full list of UTIs.

                // For: All kinds of files on the file system.
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    provider.loadItem(forTypeIdentifier: "public.file-url",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.jpeg, public.tiff, public.fax, public.jpeg-2000 , public.camera-raw-image, ...
                if provider.hasItemConformingToTypeIdentifier("public.image") {
                    provider.loadItem(forTypeIdentifier: "public.image",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.video, com.apple.quicktime-movie, public.avi, public.mpeg, public.mpeg-4 , ...
                if provider.hasItemConformingToTypeIdentifier("public.movie") {
                    provider.loadItem(forTypeIdentifier: "public.movie",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
            }
        }
    }
    
    func loadFile(coding: NSSecureCoding?, error: Error!) {
        os_log("loadFile", log: logActionExtension, type: .debug)
        
        if error != nil {
            os_log("%@", log: logActionExtension, type: .error, error.localizedDescription)
            self.digestTextField.text = "Error: Unable to load file"
            return
        }
        
        if coding != nil {
            if let url = coding as? URL {
                do {
                    self.fileData = try Data(contentsOf: url)
                } catch let error {
                    os_log("%@", log: logActionExtension, type: .error, error.localizedDescription)
                    self.calculateButton.isEnabled = false
                    self.digestTextField.text = "Error: Unable to load file"
                }
            }
        }
    }
    
    func hashFile() {
        os_log("hashFile", log: logActionExtension, type: .debug)
        
        if self.fileData != nil {
            let fileMd5Data: Data = self.fileData!.md5()
            self.digestTextField.text = fileMd5Data.map { String(format: "%02hhx", $0) }.joined()
            self.copyButton.isEnabled = true
        } else {
            self.digestTextField.text = "Error: Unable to hash file"
            self.copyButton.isEnabled = false
        }
    }
    
    func copyHash() {
        os_log("copyHash", log: logActionExtension, type: .debug)
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = self.digestTextField.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // Since we don't do anything to the file, we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let functionCell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        functionCell.textLabel?.text = "Hash function"
        functionCell.detailTextLabel?.text = "MD5"
        return functionCell
    }

}
