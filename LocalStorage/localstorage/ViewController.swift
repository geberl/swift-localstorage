//
//  ViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 01.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Positioning items inside scroll view -> needed constraints:
    // https://stackoverflow.com/a/32600396/8137043
    
    @IBOutlet weak var localFilesNumberLabel: UILabel!
    @IBOutlet weak var localFoldersNumberLabel: UILabel!
    @IBOutlet weak var localSizeBytesLabel: UILabel!
    @IBOutlet weak var localSizeDiskBytesLabel: UILabel!
    
    @IBOutlet weak var trashFilesNumberLabel: UILabel!
    @IBOutlet weak var trashFoldersNumberLabel: UILabel!
    @IBOutlet weak var trashSizeBytesLabel: UILabel!
    @IBOutlet weak var trashSizeDiskBytesLabel: UILabel!
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    @IBAction func onRefreshButton() {self.refresh()}
    @IBAction func onEmptyTrashButton() {self.emptyTrash()}
    @IBAction func onFilesButton(_ sender: UIButton) {self.showFilesApp()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        self.updatePending()
        refreshStats()
        self.updateValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }
    
    func showSettings() {
        print("Settings button pushed")
    }
    
    func refresh() {
        print("Refresh button pushed")
        
        self.updatePending()
        refreshStats()
        self.updateValues()
    }
    
    func emptyTrash() {
        print("Empty trash button pushed")
        
        removeDir(path: FileManager.documentsDir() + "/" + ".Trash")
        
        self.updatePending()
        refreshStats()
        self.updateValues()
    }
    
    func showFilesApp() {
        print("Files app button pushed")
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
        self.localFilesNumberLabel.text   = String(AppState.localFilesNumber)
        self.localFoldersNumberLabel.text = String(AppState.localFoldersNumber)
        self.localSizeBytesLabel.text     = String(AppState.localSizeBytes) + " bytes"
        self.localSizeDiskBytesLabel.text = String(AppState.localSizeDiskBytes) + " bytes"
        
        self.trashFilesNumberLabel.text   = String(AppState.trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(AppState.trashFoldersNumber)
        self.trashSizeBytesLabel.text     = String(AppState.trashSizeBytes) + " bytes"
        self.trashSizeDiskBytesLabel.text = String(AppState.trashSizeDiskBytes) + " bytes"
    }
    
}
