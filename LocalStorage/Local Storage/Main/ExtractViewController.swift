//
//  ExtractViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 01.03.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import SWCompression  // docs: https://tsolomko.github.io/SWCompression/


class ExtractViewController: UIViewController {
    
    var archiveUrl: URL? = nil
    var archiveType: String? = nil
    var archiveData: Data? = nil
    var targetDirUrl: URL? = nil
    var reachedFromExtension: Bool = false
    let dirsBlacklist: [String] = ["/__MACOSX/"]
    let fileBlacklist: [String] = [".DS_Store"]
    
    @IBAction func closeButton(_ sender: UIButton) { self.close() }
    @IBOutlet weak var archiveLabel: UILabel!
    @IBOutlet weak var compressionLabel: UILabel!
    @IBOutlet weak var compressionErrorLabel: UILabel!
    @IBOutlet weak var compressionDetailButton: UIButton!
    @IBAction func compressionDetailButton(_ sender: UIButton) { self.showCompressionDetail() }
    @IBOutlet weak var createFolderSwitch: UISwitch!
    @IBOutlet weak var deleteOnSuccessLabel: UILabel!
    @IBOutlet weak var deleteOnSuccessSwitch: UISwitch!
    @IBOutlet weak var extractButton: UIButton!
    @IBAction func extractButton(_ sender: UIButton) { self.extract() }
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: logExtractSheet, type: .debug)
        super.viewDidLoad()
        
        // Default = everything disabled, label placeholders set.
        self.compressionLabel.isHidden = true
        self.compressionErrorLabel.isHidden = false
        self.createFolderSwitch.isEnabled = false
        self.createFolderSwitch.setOn(false, animated: false)
        self.deleteOnSuccessSwitch.isEnabled = false
        self.deleteOnSuccessSwitch.setOn(false, animated: false)
        self.extractButton.isEnabled = false
        
        // Perform checks on file.
        if self.archiveUrl == nil {
            return
        }
        self.archiveLabel.text = self.archiveUrl!.lastPathComponent
        if self.reachedFromExtension == false {
            self.deleteOnSuccessSwitch.isEnabled = true
        }
        self.archiveType = self.getArchiveType()
        if self.archiveType != nil {
            self.compressionLabel.text = self.archiveType
            self.compressionLabel.isHidden = false
            self.compressionErrorLabel.isHidden = true
            self.compressionDetailButton.isHidden = true
            self.createFolderSwitch.isEnabled = true
            self.createFolderSwitch.setOn(true, animated: false)
            self.extractButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logExtractSheet, type: .debug)
        super.didReceiveMemoryWarning()
    }

    func setArchiveUrl(path: String) {
        os_log("setArchiveUrl", log: logExtractSheet, type: .debug)
        self.archiveUrl = URL(fileURLWithPath: path, isDirectory: false)
    }
    
    func setReachedFromExtension() {
        os_log("setReachedFromExtension", log: logExtractSheet, type: .debug)
        self.reachedFromExtension = true
    }

    func getArchiveType() -> String? {
        os_log("getArchiveType", log: logExtractSheet, type: .debug)
        
        if self.archiveUrl != nil {
            if let typeIdentifier = self.archiveUrl!.typeIdentifier {
                if typeIdentifier == "public.zip-archive" {
                    return "zip"
                } else if typeIdentifier == "public.tar-archive" {
                    return "tar"
                } else if typeIdentifier == "org.7-zip.7-zip-archive" {
                    return "7zip"
                }
            }
        }
        return nil
    }
    
    func close() {
        os_log("close", log: logExtractSheet, type: .debug)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showCompressionDetail() {
        os_log("showCompressionDetail", log: logExtractSheet, type: .debug)
        
        var msg: String = "Local Storage is only able to extract the types 'public.zip-archive', 'public.tar-archive' "
        msg += "and 'org.7-zip.7-zip-archive'."
        
        if self.archiveUrl != nil {
            if let typeIdentifier = self.archiveUrl!.typeIdentifier {
                msg += "\n\n"
                msg += "Your file has the type '" + typeIdentifier + "'."
            }
        }
        
        let alertController = UIAlertController(title: "Unsupported file type", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func extract() {
        os_log("extract", log: logExtractSheet, type: .debug)
        
        self.getTargetDir()
        self.loadData()  // TODO move this into background task, this might take a while
        self.openContainer()  // TODO move this into background task, this might take a while
        self.cleanUp()  // TODO move this into background task, this might take a while
        
        getStats()
        self.close()
    }
    
    func getTargetDir() {
        os_log("getTargetDir", log: logExtractSheet, type: .debug)
        
        self.targetDirUrl = URL(fileURLWithPath: AppState.documentsPath, isDirectory: true)
        self.targetDirUrl?.appendPathComponent("extract_temp") // TODO insert whatever folder the user selected here
        if self.createFolderSwitch.isOn {
            self.targetDirUrl?.appendPathComponent(self.archiveUrl!.deletingPathExtension().lastPathComponent)
        }
    }
    
    func loadData() {
        os_log("loadData", log: logExtractSheet, type: .debug)
        
        do {
            self.archiveData = try Data(contentsOf: self.archiveUrl!)
        } catch let error {
            os_log("%@", log: logExtractSheet, type: .error, error.localizedDescription)
        }
    }
    
    func openContainer() {
        os_log("openContainer", log: logExtractSheet, type: .debug)
        
        do {
            let containedEntries = try ZipContainer.open(container: self.archiveData!)
            
            for containedEntry in containedEntries {
                let myZipEntry: ZipEntry = containedEntry
                let myZipEntryInfo: ZipEntryInfo = myZipEntry.info
                
                // Check if this entry is a file (=regular) or a directory. myZipEntry.data is nil for directories.
                if myZipEntryInfo.type == .regular {
                    os_log("Found file %@.", log: logExtractSheet, type: .debug, myZipEntryInfo.name)
                    let targetFileUrl = self.targetDirUrl!.appendingPathComponent(myZipEntryInfo.name)
                    
                    // Check this filename against file blacklist.
                    if self.fileBlacklist.contains(targetFileUrl.lastPathComponent) {
                        os_log("Skipping, filename is on blacklist.", log: logExtractSheet, type: .info)
                        continue
                    }
                    
                    // Check parent folder structure against dirs blacklist.
                    var skipFile: Bool = false
                    for dirBlacklist in self.dirsBlacklist {
                        if targetFileUrl.path.range(of: dirBlacklist) != nil {
                            os_log("Skipping, parent directory is on blacklist.", log: logExtractSheet, type: .info)
                            skipFile = true
                            break
                        }
                    }
                    if skipFile { continue }
                    
                    if let myZipEntryData: Data = myZipEntry.data {
                        os_log("Writing to %@.", log: logExtractSheet, type: .info, targetFileUrl.path)
                        
                        makeDirs(path: targetFileUrl.deletingLastPathComponent().path)

                        do {
                            try myZipEntryData.write(to: targetFileUrl, options: Data.WritingOptions.atomic)
                        }
                        catch {
                            os_log("%@", log: logExtractSheet, type: .error, error.localizedDescription)
                        }
                        
                    } else {
                        os_log("Unable to get data.", log: logExtractSheet, type: .error)
                    }
                } else if myZipEntryInfo.type == .directory {
                    os_log("Found directory %@. Skipping.", log: logExtractSheet, type: .debug, myZipEntryInfo.name)
                    // Since directories are not reliably encountered before their contained files just skip over them.
                    // Instead examine the partial file path in myZipEntryInfo.name and make sure the dirs exist.
                } else {
                    os_log("Found non-supported item %@.", log: logExtractSheet, type: .error, myZipEntryInfo.name)
                    // No real way to soft and hard links and other advanced stuff on iOS.
                }
            }
        } catch let error as ZipError {
            os_log("ZipError %@", log: logExtractSheet, type: .error, error.localizedDescription)
        } catch let error {
            os_log("Error %@", log: logExtractSheet, type: .error, error.localizedDescription)
        }
    }
    
    func cleanUp() {
        os_log("cleanUp", log: logExtractSheet, type: .debug)
        
        // Remove the archive itself, but only if the user toggled the switch.
        if self.deleteOnSuccessSwitch.isOn {
            removeFileIfExist(path: self.archiveUrl!.path)
        }
        
        // Always remova all content in the App Group shared folder. Also stuff that might be in there previously.
        let appGroupName: String = "group.se.eberl.localstorage"
        if let destDirUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) {
            clearDir(path: destDirUrl.path)
        }
    }
}
