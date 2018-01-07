//
//  SettingsViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet var darkModeSwitch: UISwitch!
    @IBAction func onDarkModeSwitch(_ sender: UISwitch) {
        if self.darkModeSwitch.isOn {
            AppState.darkMode = true
        } else {
            AppState.darkMode = false
        }
    }
    
    @IBOutlet var fileSizeUnitSegCtrl: UISegmentedControl!
    @IBAction func onFileSizeUnitSegCtrl(_ sender: UISegmentedControl) {
        if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 0 {
            AppState.unit = "Bytes"
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 1 {
            AppState.unit = "KB"
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 2 {
            AppState.unit = "MB"
        } else if self.fileSizeUnitSegCtrl.selectedSegmentIndex == 3 {
            AppState.unit = "GB"
        } else {
            AppState.unit = "all"
        }
    }
    
    @IBOutlet var autoRefreshSwitch: UISwitch!
    @IBAction func onAutoRefreshSwitch(_ sender: UISwitch) {
        if self.autoRefreshSwitch.isOn {
            AppState.autoRefresh = true
        } else {
            AppState.autoRefresh = false
        }
    }
    
    @IBOutlet var askEmptyTrashSwitch: UISwitch!
    @IBAction func onAskEmptyTrashSwitch(_ sender: UISwitch) {
        if self.askEmptyTrashSwitch.isOn {
            AppState.askEmptyTrash = true
        } else {
            AppState.askEmptyTrash = false
        }
    }
    
    @IBOutlet var showAppleFilesReminder: UISwitch!
    @IBAction func showAppleFilesReminder(_ sender: UISwitch) {
        if self.showAppleFilesReminder.isOn {
            AppState.showAppleFilesReminder = true
        } else {
            AppState.showAppleFilesReminder = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadSettings() {
        self.darkModeSwitch.setOn(AppState.darkMode, animated: false)
        
        if AppState.unit == "Bytes" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 0
        } else if AppState.unit == "KB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 1
        } else if AppState.unit == "MB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 2
        } else if AppState.unit == "GB" {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 3
        } else {
            self.fileSizeUnitSegCtrl.selectedSegmentIndex = 4
        }
        
        self.autoRefreshSwitch.setOn(AppState.autoRefresh, animated: false)
        self.askEmptyTrashSwitch.setOn(AppState.askEmptyTrash, animated: false)
        self.showAppleFilesReminder.setOn(AppState.showAppleFilesReminder, animated: false)
    }
}
