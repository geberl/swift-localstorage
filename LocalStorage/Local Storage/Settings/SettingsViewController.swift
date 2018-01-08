//
//  SettingsViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet var darkModeSwitch: UISwitch!
    @IBAction func onDarkModeSwitch(_ sender: UISwitch) {
        userDefaults.set(self.darkModeSwitch.isOn, forKey: UserDefaultStruct.darkMode)
        NotificationCenter.default.post(name: .darkModeChanged, object: nil, userInfo: nil)
    }
    
    @IBOutlet var fileSizeUnitSegCtrl: UISegmentedControl!
    @IBAction func onFileSizeUnitSegCtrl(_ sender: UISegmentedControl) {
        if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 0 {
            userDefaults.set("Bytes", forKey: UserDefaultStruct.unit)
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
    
    @IBOutlet var askEmptyTrashSwitch: UISwitch!
    @IBAction func onAskEmptyTrashSwitch(_ sender: UISwitch) {
        userDefaults.set(self.askEmptyTrashSwitch.isOn, forKey: UserDefaultStruct.askEmptyTrash)
    }
    
    @IBOutlet var showAppleFilesReminderSwitch: UISwitch!
    @IBAction func onShowAppleFilesReminderSwitch(_ sender: UISwitch) {
        userDefaults.set(self.showAppleFilesReminderSwitch.isOn, forKey: UserDefaultStruct.showAppleFilesReminder)
        NotificationCenter.default.post(name: .showAppleFilesReminder, object: nil, userInfo: nil)
    }
    
    @IBOutlet var animateUpdateSwitch: UISwitch!
    @IBAction func onAnimateUpdateSwitch(_ sender: UISwitch) {
        userDefaults.set(self.animateUpdateSwitch.isOn, forKey: UserDefaultStruct.animateUpdateDuringRefresh)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadSettings() {
        self.darkModeSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.darkMode), animated: false)
        
        let unit: String = userDefaults.string(forKey: UserDefaultStruct.unit)!
        if unit == "Bytes" {
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
        self.showAppleFilesReminderSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.showAppleFilesReminder), animated: false)
        self.animateUpdateSwitch.setOn(userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh), animated: false)
    }
}
