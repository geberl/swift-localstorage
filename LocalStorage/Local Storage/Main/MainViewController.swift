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


class MainViewController: UIViewController {
    
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
    @IBAction func onRefreshButton() {self.refresh()}
    @IBAction func onEmptyTrashButton() {self.emptyTrash()}
    @IBAction func onFilesButton(_ sender: UIButton) {self.showFilesApp()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
        self.updateView()
        self.updateValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        os_log("didReceiveMemoryWarning", log: logGeneral, type: .info)
    }
    
    func updateView() {
        os_log("updateView", log: logGeneral, type: .debug)
        self.showHideAppleFilesReminder()
        self.setTheme()
    }
    
    func showHideAppleFilesReminder() {
        os_log("showHideAppleFilesReminder", log: logGeneral, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.showAppleFilesReminder) {
            fileMgntStackView.isHidden = false
        } else {
            fileMgntStackView.isHidden = true
        }
    }
    
    func setTheme() {
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
        
        self.updatePending()
        getStats()
        self.updateValues()
    }
    
    func emptyTrash() {
        os_log("emptyTrash", log: logUi, type: .debug)
        
        removeDir(path: FileManager.documentsDir() + "/" + ".Trash")
        
        self.updatePending()
        getStats()
        self.updateValues()
    }
    
    func showFilesApp() {
        os_log("showFilesApp", log: logUi, type: .debug)
        openAppStore(id: 1232058109)
    }
    
    func updatePending() {
        self.localFilesNumberLabel.text   = "..."
        self.localFoldersNumberLabel.text = "..."
        self.localSizeBytesLabel.text     = "..."
        self.localSizeDiskBytesLabel.text = "..."
        
        self.trashFilesNumberLabel.text   = "..."
        self.trashFoldersNumberLabel.text = "..."
        self.trashSizeBytesLabel.text     = "..."
        self.trashSizeDiskBytesLabel.text = "..."
    }
    
    func updateValues() {
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
        
        self.trashFilesNumberLabel.text   = String(AppState.trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(AppState.trashFoldersNumber)
        if AppState.trashSizeBytes == 0 {self.trashSizeBytesLabel.text = "0"} else {
            self.trashSizeBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.trashSizeBytes)}
        if AppState.trashSizeDiskBytes == 0 {self.trashSizeDiskBytesLabel.text = "0"} else {
            self.trashSizeDiskBytesLabel.text = byteCountFormatter.string(fromByteCount: AppState.trashSizeDiskBytes)}
    }
    
}
