//
//  AppDelegate.swift
//  localstorage
//
//  Created by Günther Eberl on 01.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit


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
    static var unit: String = "all"  // Bytes | KB | MB | GB | all
}


func resetAppState() {
    AppState.localFilesNumber = 0
    AppState.localFoldersNumber = 0
    AppState.localSizeBytes = 0
    AppState.localSizeDiskBytes = 0
    
    AppState.trashFilesNumber = 0
    AppState.trashFoldersNumber = 0
    AppState.trashSizeBytes = 0
    AppState.trashSizeDiskBytes = 0
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

