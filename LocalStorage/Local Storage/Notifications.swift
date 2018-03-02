//
//  Notifications.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let darkModeChanged = Notification.Name("darkModeChanged")
    static let unitChanged = Notification.Name("unitChanged")
    static let showHelp = Notification.Name("showHelp")
    
    static let updatePending = Notification.Name("updatePending")
    static let updateItemAdded = Notification.Name("updateItemAdded")
    static let updateFinished = Notification.Name("updateFinished")
    
    static let backFromDetail = Notification.Name("backFromDetail")
    static let launchedFromShareExtension = Notification.Name("launchedFromShareExtension")
}
