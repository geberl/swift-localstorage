//
//  Prefs.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
import os.log


struct UserDefaultStruct {
    // This struct needs to contain TWO static vars for each plist record.
    // One to set the KEY's name (type always String) and one to set the default VALUE (type accordingly).
    
    // The following variables are checked on app start and can afterwards safely be force unwrapped.
    
    static var darkMode: String = "darkMode"
    static var darkModeDefault: Bool = false
    
    static var unit: String = "unit"
    static var unitDefault: String = "all"  // Bytes | KB | MB | GB | all
    
    static var autoRefresh: String = "autoRefresh"
    static var autoRefreshDefault: Bool = true
    
    static var askEmptyTrash: String = "askEmptyTrash"
    static var askEmptyTrashDefault: Bool = true
    
    static var showAppleFilesReminder: String = "showAppleFilesReminder"
    static var showAppleFilesReminderDefault: Bool = true
    
    // The following values have no defaults and are not guaranteed to be present. No force unwrapping for those!
    // (none yet)
}


func isKeyPresentInUserDefaults(key: String) -> Bool {
    if UserDefaults.standard.object(forKey: key) == nil {
        return false
    } else {
        return true
    }
}


func ensureUserDefaults() {
    os_log("ensureUserDefaults", log: logGeneral, type: .debug)
    
    let userDefaults = UserDefaults.standard
    
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.darkMode) {
        userDefaults.set(UserDefaultStruct.darkModeDefault, forKey: UserDefaultStruct.darkMode)
    }
    
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.unit) {
        userDefaults.set(UserDefaultStruct.unitDefault, forKey: UserDefaultStruct.unit)
    }
    
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.autoRefresh) {
        userDefaults.set(UserDefaultStruct.autoRefreshDefault, forKey: UserDefaultStruct.autoRefresh)
    }
    
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.askEmptyTrash) {
        userDefaults.set(UserDefaultStruct.askEmptyTrashDefault, forKey: UserDefaultStruct.askEmptyTrash)
    }
    
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.showAppleFilesReminder) {
        userDefaults.set(UserDefaultStruct.showAppleFilesReminderDefault, forKey: UserDefaultStruct.showAppleFilesReminder)
    }
}
