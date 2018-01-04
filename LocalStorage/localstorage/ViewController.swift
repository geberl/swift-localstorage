//
//  ViewController.swift
//  mem2
//
//  Created by Günther Eberl on 01.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var localFilesNumberLabel: UILabel!
    @IBOutlet weak var localFoldersNumberLabel: UILabel!
    @IBOutlet weak var localSizeBytesLabel: UILabel!
    @IBOutlet weak var localSizeDiskBytesLabel: UILabel!
    
    @IBOutlet weak var trashFilesNumberLabel: UILabel!
    @IBOutlet weak var trashFoldersNumberLabel: UILabel!
    @IBOutlet weak var trashSizeBytesLabel: UILabel!
    @IBOutlet weak var trashSizeDiskBytesLabel: UILabel!
    
    @IBAction func onEmptyTrashButton() {
        let documentsPath = FileManager.documentsDir()
        let trashUrl: URL = URL(fileURLWithPath: documentsPath + "/.Trash", isDirectory: true)
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: trashUrl)
            print("Removed dir '" + trashUrl.path + "'")
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.listFiles()
        
    }
    
    @IBAction func onFilesButton(_ sender: UIButton) {
        // This opens the Files app in the App Store (without asking the user if he wants to do that)
        
        if let url = URL(string: "itms-apps://itunes.apple.com/de/app/files/id1232058109"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.listFiles()
        self.checkAppAvailability()
    }
    
    func listFiles() {
        let documentsPath = FileManager.documentsDir()
        print("Listing files in '" + documentsPath + "'")
        
        let fileManager = FileManager.default
        guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: documentsPath) else {
            print("Directory not found!")
            return
        }
        
        var localFilesNumber: Int = 0
        var localFoldersNumber: Int = 0
        var localSizeBytes: UInt64 = 0
        var localSizeDiskBytes: UInt64 = 0
        
        var trashFilesNumber: Int = 0
        var trashFoldersNumber: Int = 0
        var trashSizeBytes: UInt64 = 0
        var trashSizeDiskBytes: UInt64 = 0
        
        while let element = enumerator.nextObject() as? String {
            var elementURL: URL = URL(fileURLWithPath: documentsPath)
            elementURL.appendPathComponent(element)
            
            var elementIsTrashed: Bool
            if element.starts(with: ".Trash") {
                elementIsTrashed = true
            } else {
                elementIsTrashed = false
            }
            
            var fileSize : UInt64
            do {
                let attr = try fileManager.attributesOfItem(atPath: elementURL.path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                // Note: FileAttributeKey.type is useless, just contains file/folder, not UTI.
            } catch {
                fileSize = 0
                print("Error: \(error)")
            }
            
            //let fileType: String = elementURL.typeIdentifier!
            
            // print(element + " (" + String(fileSize) + ") (" + fileType + ")")
            
            // examples: (16066) = 16KB, (57110) = 57KB, (1650104250) = 1,65GB
            // only works for files
            // folders show (64) or (96), so no contained files are summed into that, this is just the name string
            
            // put notice of how to manage files in there: in the files app
            
            if let values = try? elementURL.resourceValues(forKeys: [.isDirectoryKey]) {
                if values.isDirectory! {
                    if elementIsTrashed {
                        if element != ".Trash" {
                            // Don't count the .Trash folder itself towards the folder count
                            trashFoldersNumber += 1
                        }
                        trashSizeDiskBytes += fileSize
                    } else {
                        localFoldersNumber += 1
                        localSizeDiskBytes += fileSize
                    }
                } else {
                    if elementIsTrashed {
                        trashFilesNumber += 1
                        trashSizeBytes += fileSize
                        trashSizeDiskBytes += fileSize
                    } else {
                        localFilesNumber += 1
                        localSizeBytes += fileSize
                        localSizeDiskBytes += fileSize
                    }
                }
            }
        }
        
        self.localFilesNumberLabel.text = String(localFilesNumber)
        self.localFoldersNumberLabel.text = String(localFoldersNumber)
        self.localSizeBytesLabel.text = String(localSizeBytes) + " bytes"
        self.localSizeDiskBytesLabel.text = String(localSizeDiskBytes) + " bytes"
        
        self.trashFilesNumberLabel.text = String(trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(trashFoldersNumber)
        self.trashSizeBytesLabel.text = String(trashSizeBytes) + " bytes"
        self.trashSizeDiskBytesLabel.text = String(trashSizeDiskBytes) + " bytes"
    }
    
    func checkAppAvailability() {
        // Background: The Files app is built in but can be removed
        // In which case it can be "reinstalled" through the App Store (but nothing is downloaded)
        
        // Code like this would allow to check if an app is present - if you know its URL Scheme
        // However I do not know the Files app's URL Scheme
        
        // Some URL schemes: https://github.com/cyanzhong/app-tutorials/blob/master/schemes.md
        // Some other well known ones: mailto, tel, sms, calshow, x-apple-reminder, message, maps, itms, itms-apps, ibooks, gamecenter, facetime
        // More: https://www.reddit.com/r/workflow/comments/3mux7h/ios_url_schemes/
        
        // Some stock bundle ids: https://github.com/joeblau/apple-bundle-identifiers
        // My bundle id: com.apple.DocumentsApp
        
        // URL schemes unclear if case sensitive or in-sensitive, better assume sensitive
        // Tried to guess without success: file / files / documentsapp
        // Might very well be that it has none (yet)
        
        // Note: LSApplicationQueriesSchemes must also be set in the plist to the URL string without ://
        
        var resultFb: Bool?
        resultFb = UIApplication.shared.canOpenURL(URL(string: "fb://")!)
        if resultFb != nil {
            if resultFb == true {
                print("fb:// can be opened")  // Facebook app must never have been opened, presence on device is enough
            } else {
                print("fb:// can NOT be opened")
            }
        }
        
        // The same for iOS prefs pane:
        // https://stackoverflow.com/questions/38064557/the-prefs-url-scheme-not-woring-in-ios-10-beta-1-2#42266843
        var resultPrefs: Bool?
        resultPrefs = UIApplication.shared.canOpenURL(URL(string: "App-Prefs://")!)
        if resultPrefs != nil {
            if resultPrefs == true {
                print("App-Prefs:// can be opened")
            } else {
                print("App-Prefs:// can NOT be opened")
            }
        }
        
        // And the Files app:
        var resultFiles: Bool?
        resultFiles = UIApplication.shared.canOpenURL(URL(string: "com.apple.DocumentsApp://")!)
        if resultFiles != nil {
            if resultFiles == true {
                print("Files can be opened")
            } else {
                print("Files can NOT be opened")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

