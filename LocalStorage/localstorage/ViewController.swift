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
        self.refreshStats()
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
        self.refreshStats()
    }
    
    func emptyTrash() {
        print("Empty trash button pushed")
        removeDir(path: FileManager.documentsDir() + "/" + ".Trash")
        self.refreshStats()
    }
    
    func showFilesApp() {
        print("Files app button pushed")
        openAppStore(id: 1232058109)
    }
    
    func refreshStats() {
        print("refreshStats")
        
        resetAppState()
        
        AppState.documentsPath = FileManager.documentsDir()
        print("Examining '" + AppState.documentsPath + "'")
        
        let fileManager = FileManager.default
        guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: AppState.documentsPath) else {
            print("Directory not found!")
            return
        }
        
        while let element = enumerator.nextObject() as? String {
            var elementURL: URL = URL(fileURLWithPath: AppState.documentsPath)
            elementURL.appendPathComponent(element)
            
            var elementIsTrashed: Bool
            if element.starts(with: ".Trash") {
                elementIsTrashed = true
            } else {
                elementIsTrashed = false
            }
            
            var fileSize : UInt64
            do {
                let attr = try fileManager.attributesOfItem(atPath: elementURL.path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                // Note: FileAttributeKey.type is useless, just contains file/folder, not UTI.
            } catch {
                fileSize = 0
                print("Error: \(error)")
            }
            
            //let fileType: String = elementURL.typeIdentifier!
            
            // print(element + " (" + String(fileSize) + ") (" + fileType + ")")
            
            // examples: (16066) = 16KB, (57110) = 57KB, (1650104250) = 1,65GB
            // only works for files
            // folders show (64) or (96), so no contained files are summed into that, this is just the name string
            
            // put notice of how to manage files in there: in the files app
            
            if let values = try? elementURL.resourceValues(forKeys: [.isDirectoryKey]) {
                if values.isDirectory! {
                    if elementIsTrashed {
                        if element != ".Trash" {
                            // Don't count the .Trash folder itself towards the folder count
                            AppState.trashFoldersNumber += 1
                        }
                        AppState.trashSizeDiskBytes += fileSize
                    } else {
                        AppState.localFoldersNumber += 1
                        AppState.localSizeDiskBytes += fileSize
                    }
                } else {
                    if elementIsTrashed {
                        AppState.trashFilesNumber += 1
                        AppState.trashSizeBytes += fileSize
                        AppState.trashSizeDiskBytes += fileSize
                    } else {
                        AppState.localFilesNumber += 1
                        AppState.localSizeBytes += fileSize
                        AppState.localSizeDiskBytes += fileSize
                    }
                }
            }
        }
        
        self.updateValues()
    }
    
    func updateValues() {
        self.localFilesNumberLabel.text = String(AppState.localFilesNumber)
        self.localFoldersNumberLabel.text = String(AppState.localFoldersNumber)
        self.localSizeBytesLabel.text = String(AppState.localSizeBytes) + " bytes"
        self.localSizeDiskBytesLabel.text = String(AppState.localSizeDiskBytes) + " bytes"
        
        self.trashFilesNumberLabel.text = String(AppState.trashFilesNumber)
        self.trashFoldersNumberLabel.text = String(AppState.trashFoldersNumber)
        self.trashSizeBytesLabel.text = String(AppState.trashSizeBytes) + " bytes"
        self.trashSizeDiskBytesLabel.text = String(AppState.trashSizeDiskBytes) + " bytes"
    }
    
}
