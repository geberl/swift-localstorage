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


func checkAppAvailability(registeredUrl: URL) -> Bool {
    // Background: The Files app is built in but can be removed.
    // In which case it can be "reinstalled" through the App Store (but nothing is downloaded).
    
    // Code like this would allow to check if an app is present - if you know its URL Scheme.
    // However I do not know the Files app's URL Scheme.
    // It's even unclear at this moment (2018-01-04) if it has an URL Scheme associated with it.
    
    // Some URL schemes: https://github.com/cyanzhong/app-tutorials/blob/master/schemes.md
    // More: https://www.reddit.com/r/workflow/comments/3mux7h/ios_url_schemes/
    
    // Some stock bundle ids: https://github.com/joeblau/apple-bundle-identifiers
    // The files app bundle id (I know this for sure): com.apple.DocumentsApp
    // However this is not enough, I would need to access a private API for querying (like Workflow probably does and is allowed to because Apple).
    // Using private APIs leads to Apple not letting you into their App Store.
    
    // URL schemes unclear if case sensitive or in-sensitive, better assume sensitive.
    // Tried to guess without success: file / files / documentsapp
    
    // Note: LSApplicationQueriesSchemes must also be set in the plist to the URL string without ://
    
    // So this function as of now doesn't do anything useful.
    // I first need to know the Files apps URL scheme.
    
    // These apps must never have been opened, presence on device is enough, URL seems to be registered on installation
    
    // More info about iOS prefs pane:
    // https://stackoverflow.com/questions/38064557/the-prefs-url-scheme-not-woring-in-ios-10-beta-1-2#42266843
    
    // Examples:
    // checkAppAvailability(registeredUrl: URL(string: "fb://")!)
    // checkAppAvailability(registeredUrl: URL(string: "App-Prefs://")!)
    // checkAppAvailability(registeredUrl: URL(string: "com.apple.DocumentsApp://")!)  // doesn't work
    
    var checkResult: Bool?
    checkResult = UIApplication.shared.canOpenURL(registeredUrl)
    if checkResult != nil {
        if checkResult == true {
            return true
        }
    }
    return false
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
    
    AppState.types = [TypeInfo(name: "Audio", color: UIColor(named: "ColorTypeAudio")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Videos", color: UIColor(named: "ColorTypeVideos")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Documents", color: UIColor(named: "ColorTypeDocuments")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Images", color: UIColor(named: "ColorTypeImages")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Code", color: UIColor(named: "ColorTypeCode")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Archives", color: UIColor(named: "ColorTypeArchives")!, size: 0, number: 0, paths: [], sizes: []),
                      TypeInfo(name: "Other", color: UIColor(named: "ColorTypeOther")!, size: 0, number: 0, paths: [], sizes: [])]
}


func addToType(name: String, size: Int64, path: String) {
    for (n, type_info) in AppState.types.enumerated() {
        if type_info.name == name {
            AppState.types[n].size += size
            AppState.types[n].number += 1
            let documentsPathEndIndex = path.index(AppState.documentsPath.endIndex, offsetBy: 1)
            AppState.types[n].paths.append(String(path[documentsPathEndIndex...]))
            AppState.types[n].sizes.append(size)
            break
        }
    }
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
                    addToType(name: "Audio", size: fileSize, path: elementURL.path)
                } else if TypesLookup.videos.contains(fileType) {
                    addToType(name: "Videos", size: fileSize, path: elementURL.path)
                } else if TypesLookup.documents.contains(fileType) {
                    addToType(name: "Documents", size: fileSize, path: elementURL.path)
                } else if TypesLookup.images.contains(fileType) {
                    addToType(name: "Images", size: fileSize, path: elementURL.path)
                } else if TypesLookup.code.contains(fileType) {
                    addToType(name: "Code", size: fileSize, path: elementURL.path)
                } else if TypesLookup.archives.contains(fileType) {
                    addToType(name: "Archives", size: fileSize, path: elementURL.path)
                } else {
                    addToType(name: "Other", size: fileSize, path: elementURL.path)
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

func getFreeSpace() -> Int64? {
    // Source: https://stackoverflow.com/questions/26198073/query-available-ios-disk-space-with-swift#26198164
    
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    guard
        let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
        let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else { return nil }
    return freeSize.int64Value
}
