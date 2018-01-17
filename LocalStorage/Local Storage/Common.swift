//
//  Common.swift
//  localstorage
//
//  Created by Günther Eberl on 05.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
import UIKit
import os.log


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


func getSizeString(byteCount: Int64) -> String {
    // Get a human readable size string according to user preferences.
    
    let userDefaults = UserDefaults.standard
    let unit: String = userDefaults.string(forKey: UserDefaultStruct.unit)!
    
    if byteCount == 0 {
        if unit == "all" {
            return "0 bytes"
        }
        return "0 " + unit
    }
    
    let byteCountFormatter = ByteCountFormatter()
    if unit == "bytes" {
        byteCountFormatter.allowedUnits = .useBytes
    } else if unit == "KB" {
        byteCountFormatter.allowedUnits = .useKB
    } else if unit == "MB" {
        byteCountFormatter.allowedUnits = .useMB
    } else if unit == "GB" {
        byteCountFormatter.allowedUnits = .useGB
    } else {
        byteCountFormatter.allowedUnits = .useAll
    }
    byteCountFormatter.countStyle = .file
    
    return byteCountFormatter.string(fromByteCount: byteCount)
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
        os_log("Removed dir '%@'", log: logGeneral, type: .info, dirUrl.path)
    } catch let error {
        os_log("%@", log: logGeneral, type: .error, error.localizedDescription)
    }
}


func resetStats() {
    os_log("resetStats", log: logGeneral, type: .debug)
    
    AppState.localFilesNumber = 0
    AppState.localFoldersNumber = 0
    AppState.localSizeBytes = 0
    AppState.localSizeDiskBytes = 0
    
    AppState.trashFilesNumber = 0
    AppState.trashFoldersNumber = 0
    AppState.trashSizeBytes = 0
    AppState.trashSizeDiskBytes = 0
    
    AppState.typeSizeAudio = 0
    AppState.typeSizeVideos = 0
    AppState.typeSizeDocuments = 0
    AppState.typeSizeImages = 0
    AppState.typeSizeCode = 0
    AppState.typeSizeOther = 0
    
    AppState.typeNumberAudio = 0
    AppState.typeNumberVideos = 0
    AppState.typeNumberDocuments = 0
    AppState.typeNumberImages = 0
    AppState.typeNumberCode = 0
    AppState.typeNumberOther = 0
}


func getStats() {
    os_log("getStats", log: logGeneral, type: .debug)
    
    let userDefaults = UserDefaults.standard
    let sendUpdateItemNotification: Bool = userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh)
    
    AppState.updateInProgress = true
    resetStats()
    NotificationCenter.default.post(name: .updatePending, object: nil, userInfo: nil)
    
    // Actual file system traversing is done asynchronously to not block the UI.
    DispatchQueue.global(qos: .userInitiated).async {

        let fileManager = FileManager.default
        guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: AppState.documentsPath) else {
            os_log("Directory not found '%@'", log: logGeneral, type: .error, AppState.documentsPath)
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
            
            var fileSize : Int64
            do {
                let attr = try fileManager.attributesOfItem(atPath: elementURL.path)
                fileSize = attr[FileAttributeKey.size] as! Int64
                // Note: FileAttributeKey.type is useless, just contains file/folder, not UTI.
            } catch {
                fileSize = 0
                os_log("%@", log: logGeneral, type: .error, error.localizedDescription)
            }
            
            if let fileType: String = elementURL.typeIdentifier {
                if TypesLookup.audio.contains(fileType) {
                    AppState.typeSizeAudio += fileSize
                    AppState.typeNumberAudio += 1
                } else if TypesLookup.videos.contains(fileType) {
                    AppState.typeSizeVideos += fileSize
                    AppState.typeNumberVideos += 1
                } else if TypesLookup.documents.contains(fileType) {
                    AppState.typeSizeDocuments += fileSize
                    AppState.typeNumberDocuments += 1
                } else if TypesLookup.images.contains(fileType) {
                    AppState.typeSizeImages += fileSize
                    AppState.typeNumberImages += 1
                } else if TypesLookup.code.contains(fileType) {
                    AppState.typeSizeCode += fileSize
                    AppState.typeNumberCode += 1
                } else if TypesLookup.archives.contains(fileType) {
                    AppState.typeSizeArchives += fileSize
                    AppState.typeNumberArchives += 1
                } else {
                    AppState.typeSizeOther += fileSize
                    AppState.typeNumberOther += 1
                    if !TypesLookup.other.contains(fileType) {
                        if !fileType.starts(with: "dyn.") {
                            print(" Type identifier unknown for '" + fileType + "'")
                            print("  " + elementURL.path)
                        }
                    }
                }
            } else {
                os_log("Unable to get type identifier for '%@'", log: logGeneral, type: .error, elementURL.path)
            }
            
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
            
            // Update stats after each file.
            if sendUpdateItemNotification {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .updateItemAdded, object: nil, userInfo: nil)
                }
            }
        }
        
        // Update stats after traversing completed.
        DispatchQueue.main.async {
            AppState.updateInProgress = false
            NotificationCenter.default.post(name: .updateFinished, object: nil, userInfo: nil)
        }
    }
}
