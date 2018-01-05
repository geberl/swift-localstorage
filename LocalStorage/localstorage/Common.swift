//
//  Common.swift
//  localstorage
//
//  Created by Günther Eberl on 05.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
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


func checkAppAvailability() {
    // Background: The Files app is built in but can be removed.
    // In which case it can be "reinstalled" through the App Store (but nothing is downloaded).
    
    // Code like this would allow to check if an app is present - if you know its URL Scheme.
    // However I do not know the Files app's URL Scheme.
    // It's even unclear at this moment (2018-01-04) if it has an URL Scheme associated with it.
    
    // Some URL schemes: https://github.com/cyanzhong/app-tutorials/blob/master/schemes.md
    // More: https://www.reddit.com/r/workflow/comments/3mux7h/ios_url_schemes/
    
    // Some stock bundle ids: https://github.com/joeblau/apple-bundle-identifiers
    // The files app bundle id: com.apple.DocumentsApp
    // However this is not enough, I would need to access a private API for querying (like Workflow probably does).
    // Using private APIs leads to Apple not letting you into their App Store.
    
    // URL schemes unclear if case sensitive or in-sensitive, better assume sensitive.
    // Tried to guess without success: file / files / documentsapp
    
    // Note: LSApplicationQueriesSchemes must also be set in the plist to the URL string without ://
    
    // So this function as of now doesn't do anything useful.
    // I first need to know the Files apps URL scheme.
    
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


func openAppStore(id: Int) {
    // This opens the page for an app in the App Store without asking the user for confirmation
    // Apple Files: 1232058109
    
    if let url = URL(string: "itms-apps://itunes.apple.com/de/app/files/id" + String(id)),
        UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


func removeDir(path: String) {
    let dirUrl: URL = URL(fileURLWithPath: path, isDirectory: true)
    
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(at: dirUrl)
        print("Removed dir '" + dirUrl.path + "'")
    } catch let error {
        print(error.localizedDescription)
    }
}


func refreshStats() {
    print("refreshStats")
    
    resetAppState()
    
    AppState.documentsPath = FileManager.documentsDir()
    print("Examining '" + AppState.documentsPath + "'")
    
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: AppState.documentsPath) else {
        print("Directory not found!")
        return
    }
    
    while let element = enumerator.nextObject() as? String {
        var elementURL: URL = URL(fileURLWithPath: AppState.documentsPath)
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
                        AppState.trashFoldersNumber += 1
                    }
                    AppState.trashSizeDiskBytes += fileSize
                } else {
                    AppState.localFoldersNumber += 1
                    AppState.localSizeDiskBytes += fileSize
                }
            } else {
                if elementIsTrashed {
                    AppState.trashFilesNumber += 1
                    AppState.trashSizeBytes += fileSize
                    AppState.trashSizeDiskBytes += fileSize
                } else {
                    AppState.localFilesNumber += 1
                    AppState.localSizeBytes += fileSize
                    AppState.localSizeDiskBytes += fileSize
                }
            }
        }
    }
}
