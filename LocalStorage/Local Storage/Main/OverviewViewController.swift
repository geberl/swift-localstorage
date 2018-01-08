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
    
    @IBOutlet var parentUiView: UIView!
    @IBOutlet weak var headlineLabel: UILabel!
    
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
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    
    @IBOutlet var refreshButton: UIButton!
    @IBAction func onRefreshButton() {self.refresh()}
    
    @IBOutlet var emptyTrashButton: UIButton!
    @IBAction func onEmptyTrashButton() {self.askEmptyTrash()}
    
    @IBAction func onFilesButton(_ sender: UIButton) {self.showFilesApp()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
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
                                               name: .showAppleFilesReminder, object: nil)
        
        self.setTheme()
        self.showHideAppleFilesReminder()
        
        if AppState.updateInProgress {
            self.updatePending()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        os_log("didReceiveMemoryWarning", log: logGeneral, type: .info)
    }
    
    @objc func showHideAppleFilesReminder() {
        os_log("showHideAppleFilesReminder", log: logGeneral, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.showAppleFilesReminder) {
            fileMgntStackView.isHidden = false
        } else {
            fileMgntStackView.isHidden = true
        }
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logGeneral, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logGeneral, type: .debug)
        let fgColor: UIColor = UIColor(named: fg)!
        let bgColor: UIColor = UIColor(named: bg)!
        
        parentUiView.backgroundColor = bgColor
        
        headlineLabel.textColor = fgColor
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
    }
    
    func showSettings() {
        os_log("showSettings", log: logUi, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: false, completion: nil)
    }
    
    func refresh() {
        os_log("refresh", log: logUi, type: .debug)
        getStats()
    }
    
    func askEmptyTrash() {
        os_log("askEmptyTrash", log: logUi, type: .debug)
        
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
        os_log("emptyTrash", log: logGeneral, type: .debug)
        
        removeDir(path: FileManager.documentsDir() + "/" + ".Trash")
        getStats()
    }
    
    func showFilesApp() {
        os_log("showFilesApp", log: logUi, type: .debug)
        
        openAppStore(id: 1232058109)
    }
    
    @objc func updatePending() {
        os_log("updatePending", log: logGeneral, type: .debug)

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
        let unit: String = userDefaults.string(forKey: UserDefaultStruct.unit)!
        let byteCountFormatter = ByteCountFormatter()
        if unit == "Bytes" {
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
        
        self.localFilesNumberLabel.text = String(AppState.localFilesNumber)
        self.localFoldersNumberLabel.text = String(AppState.localFoldersNumber)
        if AppState.localSizeBytes == 0 {self.localSizeBytesLabel.text = "0"} else {
            self.localSizeBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.localSizeBytes)}
        if AppState.localSizeDiskBytes == 0 {self.localSizeDiskBytesLabel.text = "0"} else {
            self.localSizeDiskBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.localSizeDiskBytes)}
        
        if !AppState.updateInProgress {
            self.refreshButton.isEnabled = true
        }
        
        self.trashFilesNumberLabel.text   = String(AppState.trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(AppState.trashFoldersNumber)
        if AppState.trashSizeBytes == 0 {self.trashSizeBytesLabel.text = "0"} else {
            self.trashSizeBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.trashSizeBytes)}
        if AppState.trashSizeDiskBytes == 0 {
            self.trashSizeDiskBytesLabel.text = "0"
            self.emptyTrashButton.isEnabled = false
        } else {
            self.trashSizeDiskBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.trashSizeDiskBytes)
            if !AppState.updateInProgress {
                self.emptyTrashButton.isEnabled = true
            }
        }
    }
    
}
