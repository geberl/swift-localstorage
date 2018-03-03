//
//  ExtractViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 01.03.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import SWCompression


// Documentation of SWCompression: https://tsolomko.github.io/SWCompression/


class ExtractViewController: UIViewController {
    
    var archiveUrl: URL? = nil
    var archiveData: Data? = nil
    var targetDirUrl: URL? = nil
    
    func setArchiveUrl(path: String) {
        os_log("setArchiveUrl", log: logUi, type: .debug)
        self.archiveUrl = URL(fileURLWithPath: path, isDirectory: false)
    }

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logUi, type: .debug)
        super.viewDidLoad()
        
        // TODO make targetDirUrl user selectable in GUI. Create this folder.
        self.targetDirUrl = URL(fileURLWithPath: AppState.documentsPath, isDirectory: true)
        self.targetDirUrl?.appendPathComponent("extract_temp")
        
        if self.archiveUrl != nil {
            self.archiveLabel.text = self.archiveUrl?.lastPathComponent
            self.extractButton.isEnabled = true
        } else {
            self.archiveLabel.text = "???"
            self.extractButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var archiveLabel: UILabel!
    
    @IBOutlet weak var extractButton: UIButton!
    
    @IBAction func onExtractButton(_ sender: UIButton) {
        os_log("onExtractButton", log: logUi, type: .debug)
        self.loadData()
        self.openContainer()
    }
    
    func loadData() {
        os_log("loadData", log: logUi, type: .debug)
        
        do {
            self.archiveData = try Data(contentsOf: self.archiveUrl!)
        } catch let error {
            os_log("%@", log: logUi, type: .error, error.localizedDescription)
        }
    }
    
    func openContainer() {
        os_log("openContainer", log: logUi, type: .debug)
        
        do {
            let containedEntries = try ZipContainer.open(container: self.archiveData!)
            
            for containedEntry in containedEntries {
                let myZipEntry: ZipEntry = containedEntry
                let myZipEntryInfo: ZipEntryInfo = myZipEntry.info
                
                // Check if this entry is a file (=regular) or a directory. myZipEntry.data is nil for directories.
                if myZipEntryInfo.type == .regular {
                    os_log("Found file %@", log: logUi, type: .debug, myZipEntryInfo.name)
                    
                    if let myZipEntryData: Data = myZipEntry.data {
                        let targetFileUrl = self.targetDirUrl!.appendingPathComponent(myZipEntryInfo.name)
                        os_log("Writing to %@", log: logUi, type: .error, targetFileUrl.path)
                        
                        // TODO: Check if dir structure already exists, make it if not. Writing fails otherwise.
                        
                        do {
                            try myZipEntryData.write(to: targetFileUrl, options: Data.WritingOptions.atomic)
                        }
                        catch {
                            os_log("Unable to write data (%@).", log: logUi, type: .error, error.localizedDescription)
                        }
                        
                    } else {
                        os_log("Unable to get data.", log: logUi, type: .error)
                    }
                } else if myZipEntryInfo.type == .directory {
                    os_log("Found directory %@", log: logUi, type: .debug, myZipEntryInfo.name)
                    // Since directories are not reliably encountered before their contained files just skip over them.
                    // Instead examine the partial file path in myZipEntryInfo.name and make sure the dirs exist.
                } else {
                    os_log("Found other %@", log: logUi, type: .error, myZipEntryInfo.name)
                    // This should not occur.
                }
            }
        } catch let error as ZipError {
            os_log("ZipError %@", log: logUi, type: .error, error.localizedDescription)
        } catch let error {
            os_log("Error %@", log: logUi, type: .error, error.localizedDescription)
        }
    }
    
}
