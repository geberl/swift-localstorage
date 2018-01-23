//
//  SettingsViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log


class SettingsViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        os_log("onCloseButton", log: logSettings, type: .debug)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var darkModeSwitch: UISwitch!
    @IBAction func onDarkModeSwitch(_ sender: UISwitch) {
        os_log("onDarkModeSwitch", log: logSettings, type: .debug)
        userDefaults.set(self.darkModeSwitch.isOn, forKey: UserDefaultStruct.darkMode)
        NotificationCenter.default.post(name: .darkModeChanged, object: nil, userInfo: nil)
    }
    
    @IBOutlet var fileSizeUnitSegCtrl: UISegmentedControl!
    @IBAction func onFileSizeUnitSegCtrl(_ sender: UISegmentedControl) {
        os_log("onFileSizeUnitSegCtrl", log: logSettings, type: .debug)
        if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 0 {
            userDefaults.set("bytes", forKey: UserDefaultStruct.unit)
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 1 {
            userDefaults.set("KB", forKey: UserDefaultStruct.unit)
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 2 {
            userDefaults.set("MB", forKey: UserDefaultStruct.unit)
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 3 {
            userDefaults.set("GB", forKey: UserDefaultStruct.unit)
        } else {
            userDefaults.set("all", forKey: UserDefaultStruct.unit)
        }
        NotificationCenter.default.post(name: .unitChanged, object: nil, userInfo: nil)
    }
    
    @IBOutlet var animateUpdateSwitch: UISwitch!
    @IBAction func onAnimateUpdateSwitch(_ sender: UISwitch) {
        os_log("onAnimateUpdateSwitch", log: logSettings, type: .debug)
        userDefaults.set(self.animateUpdateSwitch.isOn, forKey: UserDefaultStruct.animateUpdateDuringRefresh)
    }
    
    @IBOutlet var askEmptyTrashSwitch: UISwitch!
    @IBAction func onAskEmptyTrashSwitch(_ sender: UISwitch) {
        os_log("onAskEmptyTrashSwitch", log: logSettings, type: .debug)
        userDefaults.set(self.askEmptyTrashSwitch.isOn, forKey: UserDefaultStruct.askEmptyTrash)
    }
    
    @IBOutlet var showHelpSwitch: UISwitch!
    @IBAction func onShowHelpSwitch(_ sender: UISwitch) {
        os_log("onShowHelpSwitch", log: logSettings, type: .debug)
        userDefaults.set(self.showHelpSwitch.isOn, forKey: UserDefaultStruct.showHelp)
        NotificationCenter.default.post(name: .showHelp, object: nil, userInfo: nil)
    }
    
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: logSettings, type: .debug)
        super.viewDidLoad()
        self.loadSettings()
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logSettings, type: .debug)
        super.didReceiveMemoryWarning()
    }
    
    func loadSettings() {
        os_log("loadSettings", log: logSettings, type: .debug)
        
        self.darkModeSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.darkMode), animated: false)
        
        let unit: String = userDefaults.string(forKey: UserDefaultStruct.unit)!
        if unit == "bytes" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 0
        } else if unit == "KB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 1
        } else if unit == "MB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 2
        } else if unit == "GB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 3
        } else {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 4
        }
        
        self.askEmptyTrashSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.askEmptyTrash), animated: false)
        self.showHelpSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.showHelp), animated: false)
        self.animateUpdateSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh), animated: false)
    }
}
