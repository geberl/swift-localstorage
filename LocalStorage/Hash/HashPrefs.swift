//
//  HashPrefs.swift
//  Hash
//
//  Created by Günther Eberl on 06.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation
import os.log


struct UserDefaultStruct {
    static var hashFunction: String = "hashFunction"
    static var hashFunctionDefault: String = "MD5"  // CRC32 | MD2 | MD4 | MD5 | SHA1 | SHA224 | SHA256 | SHA384 | SHA512
}


func isKeyPresentInUserDefaults(key: String) -> Bool {
    if UserDefaults.standard.object(forKey: key) == nil {
        return false
    } else {
        return true
    }
}


func ensureUserDefaults() {
    os_log("ensureUserDefaults", log: logHashExtension, type: .debug)
    
    let userDefaults = UserDefaults.standard
    if !isKeyPresentInUserDefaults(key: UserDefaultStruct.hashFunction) {
        userDefaults.set(UserDefaultStruct.hashFunctionDefault, forKey: UserDefaultStruct.hashFunction)
    }
}
