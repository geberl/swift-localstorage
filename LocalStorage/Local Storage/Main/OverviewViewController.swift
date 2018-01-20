//
//  ViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 01.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

// Positioning items inside scroll view -> needed constraints:
// https://stackoverflow.com/a/32600396/8137043


import UIKit
import os.log


class OverviewViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet var mainView: UIView!

    @IBOutlet weak var localFilesLabel: UILabel!
    @IBOutlet weak var localFilesNumberLabel: UILabel!
    
    @IBOutlet weak var localFoldersLabel: UILabel!
    @IBOutlet weak var localFoldersNumberLabel: UILabel!
    
    @IBOutlet weak var localSizeLabel: UILabel!
    @IBOutlet weak var localSizeBytesLabel: UILabel!
    
    @IBOutlet weak var localSizeDiskLabel: UILabel!
    @IBOutlet weak var localSizeDiskBytesLabel: UILabel!
    
    @IBOutlet weak var trashFilesLabel: UILabel!
    @IBOutlet weak var trashFilesNumberLabel: UILabel!
    
    @IBOutlet weak var trashFoldersLabel: UILabel!
    @IBOutlet weak var trashFoldersNumberLabel: UILabel!
    
    @IBOutlet weak var trashSizeLabel: UILabel!
    @IBOutlet weak var trashSizeBytesLabel: UILabel!
    
    @IBOutlet weak var trashSizeDiskLabel: UILabel!
    @IBOutlet weak var trashSizeDiskBytesLabel: UILabel!
    
    @IBOutlet weak var fileMgntStackView: UIStackView!
    @IBOutlet weak var reminderLineOneLabel: UILabel!
    @IBOutlet weak var reminderLineTwoLabel: UILabel!
    @IBOutlet weak var reminderLineThreeLabel: UILabel!
    @IBOutlet weak var reminderLineFourLabel: UILabel!
    
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    
    @IBOutlet var refreshButton: UIButton!
    @IBAction func onRefreshButton() {self.refresh()}
    
    @IBOutlet var emptyTrashButton: UIButton!
    @IBAction func onEmptyTrashButton() {self.askEmptyTrash()}
    
    @IBAction func onFilesButton(_ sender: UIButton) {self.showFilesApp()}
    
    @IBAction func onPreferencesButton(_ sender: UIButton) {self.openPreferences()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logTabOverview, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.updatePending),
                                               name: .updatePending, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.updateValues),
                                               name: .updateFinished, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.updateValues),
                                               name: .updateItemAdded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.updateValues),
                                               name: .unitChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.showHideAppleFilesReminder),
                                               name: .showHelp, object: nil)
        
        self.setTheme()
        self.showHideAppleFilesReminder()
        
        if AppState.updateInProgress {
            self.updatePending()
        }
        
        if let bytes = getFreeSpace() {
            print("Free space: \(getSizeString(byteCount: bytes))")
        } else {
            print("Failed")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        os_log("didReceiveMemoryWarning", log: logTabOverview, type: .info)
    }
    
    @objc func showHideAppleFilesReminder() {
        os_log("showHideAppleFilesReminder", log: logTabOverview, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.showHelp) {
            fileMgntStackView.isHidden = false
        } else {
            fileMgntStackView.isHidden = true
        }
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabOverview, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabOverview, type: .debug)
        let fgColor: UIColor = UIColor(named: fg)!
        let bgColor: UIColor = UIColor(named: bg)!
        
        mainView.backgroundColor = bgColor
        
        localFilesLabel.textColor = fgColor
        localFilesNumberLabel.textColor = fgColor
        localFoldersLabel.textColor = fgColor
        localFoldersNumberLabel.textColor = fgColor
        localSizeLabel.textColor = fgColor
        localSizeBytesLabel.textColor = fgColor
        localSizeDiskLabel.textColor = fgColor
        localSizeDiskBytesLabel.textColor = fgColor
        trashFilesLabel.textColor = fgColor
        trashFilesNumberLabel.textColor = fgColor
        trashFoldersLabel.textColor = fgColor
        trashFoldersNumberLabel.textColor = fgColor
        trashSizeLabel.textColor = fgColor
        trashSizeBytesLabel.textColor = fgColor
        trashSizeDiskLabel.textColor = fgColor
        trashSizeDiskBytesLabel.textColor = fgColor
        reminderLineOneLabel.textColor = fgColor
        reminderLineTwoLabel.textColor = fgColor
        reminderLineThreeLabel.textColor = fgColor
        reminderLineFourLabel.textColor = fgColor
    }
    
    func showSettings() {
        os_log("showSettings", log: logTabOverview, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }
    
    func refresh() {
        os_log("refresh", log: logTabOverview, type: .debug)
        getStats()
    }
    
    func askEmptyTrash() {
        os_log("askEmptyTrash", log: logTabOverview, type: .debug)
        
        if userDefaults.bool(forKey: UserDefaultStruct.askEmptyTrash) {
            let alert = UIAlertController(title: "Are you sure you want to permanently erase all items in the Trash?",
                                          message: "You can't undo this action",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .`default`, handler: { _ in
                os_log("Alert action: Cancel", log: logUi, type: .debug)
            }))
            alert.addAction(UIAlertAction(title: "Empty Trash", style: .`default`, handler: { _ in
                os_log("Alert action: Empty Trash", log: logUi, type: .debug)
                self.emptyTrash()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.emptyTrash()
        }
    }
    
    func emptyTrash() {
        os_log("emptyTrash", log: logTabOverview, type: .debug)
        
        removeDir(path: FileManager.documentsDir() + "/" + ".Trash")
        getStats()
    }
    
    func showFilesApp() {
        os_log("showFilesApp", log: logTabOverview, type: .debug)
        
        openAppStore(id: 1232058109)
    }
    
    func openPreferences() {
        os_log("openPreferences", log: logTabOverview, type: .debug)
        
        let prefsStorage: URL = URL(string: "App-Prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE")!
        let prefsStart: URL = URL(string: "App-Prefs://")!
        
        if checkAppAvailability(registeredUrl: prefsStorage) {
            UIApplication.shared.open(prefsStorage, options: [:], completionHandler: nil)
        } else {
            os_log("Preferences/General/Storage can't be opened.", log: logTabOverview, type: .error)
            if checkAppAvailability(registeredUrl: prefsStart) {
                UIApplication.shared.open(prefsStart, options: [:], completionHandler: nil)
            } else {
                os_log("Preferences can't be opened.", log: logTabOverview, type: .error)
            }
        }
    }
    
    @objc func updatePending() {
        os_log("updatePending", log: logTabOverview, type: .debug)
        
        self.localFilesNumberLabel.text   = "..."
        self.localFoldersNumberLabel.text = "..."
        self.localSizeBytesLabel.text     = "..."
        self.localSizeDiskBytesLabel.text = "..."
        
        self.refreshButton.isEnabled = false
        
        self.trashFilesNumberLabel.text   = "..."
        self.trashFoldersNumberLabel.text = "..."
        self.trashSizeBytesLabel.text     = "..."
        self.trashSizeDiskBytesLabel.text = "..."
        
        self.emptyTrashButton.isEnabled = false
    }
    
    @objc func updateValues() {
        self.localFilesNumberLabel.text = String(AppState.localFilesNumber)
        self.localFoldersNumberLabel.text = String(AppState.localFoldersNumber)
        
        self.localSizeBytesLabel.text = getSizeString(byteCount: AppState.localSizeBytes)
        self.localSizeDiskBytesLabel.text = getSizeString(byteCount: AppState.localSizeDiskBytes)
        
        if AppState.updateInProgress {
            self.refreshButton.isEnabled = false
        } else {
            self.refreshButton.isEnabled = true
        }
        
        self.trashFilesNumberLabel.text   = String(AppState.trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(AppState.trashFoldersNumber)
        
        self.trashSizeBytesLabel.text = getSizeString(byteCount: AppState.trashSizeBytes)
        self.trashSizeDiskBytesLabel.text = getSizeString(byteCount: AppState.trashSizeDiskBytes)
        
        if AppState.trashSizeDiskBytes == 0 || AppState.updateInProgress {
            self.emptyTrashButton.isEnabled = false
        } else {
            self.emptyTrashButton.isEnabled = true
        }
    }
    
}
