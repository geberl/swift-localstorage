//
//  AppDelegate.swift
//  localstorage
//
//  Created by Günther Eberl on 01.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log


// Logger configuration.
let logGeneral = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "general")
let logUi = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ui")


// Global application state object.
struct AppState {
    static var localFilesNumber: Int64 = 0
    static var localFoldersNumber: Int64 = 0
    static var localSizeBytes: Int64 = 0
    static var localSizeDiskBytes: Int64 = 0
    
    static var trashFilesNumber: Int64 = 0
    static var trashFoldersNumber: Int64 = 0
    static var trashSizeBytes: Int64 = 0
    static var trashSizeDiskBytes: Int64 = 0
    
    static var documentsPath: String = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Note concerning images and custom fonts on LaunchScreen:
        // These things might not show up correctly when newly added. They are somehow cached in the device between runs even though a new build is triggered and/or the app is uninstalled/reinstalled. The only thing that helps is rebooting or running a (fresh) emulator.
        
        os_log("didFinishLaunchingWithOptions", log: logGeneral, type: .debug)
        
        ensureUserDefaults()
        AppState.documentsPath = FileManager.documentsDir()
        getStats()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        os_log("applicationWillResignActive", log: logGeneral, type: .debug)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // Example: Home button pressed.
        os_log("applicationDidEnterBackground", log: logGeneral, type: .debug)
        resetStats()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        // This will however not execute on initial launch.
        // Example: Re-launched from home screen after just previously hidden by pressing home button.
        os_log("applicationWillEnterForeground", log: logGeneral, type: .debug)
        getStats()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        os_log("applicationDidBecomeActive", log: logGeneral, type: .debug)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        os_log("applicationWillTerminate", log: logGeneral, type: .debug)
    }

}

