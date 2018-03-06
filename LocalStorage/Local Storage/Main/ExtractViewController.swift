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
    var reachedFromExtension: Bool = false
    
    var archiveType: String? = nil
    var archiveData: Data? = nil
    var targetDirUrl: URL? = nil
    let dirsBlacklist: [String] = ["/__MACOSX/"]
    let fileBlacklist: [String] = [".DS_Store"]
    
    @IBAction func onDoneButton(_ sender: UIBarButtonItem) { self.close() }
    @IBOutlet weak var archiveLabel: UILabel!
    @IBOutlet weak var compressionLabel: UILabel!
    @IBOutlet weak var compressionErrorLabel: UILabel!
    @IBOutlet weak var compressionDetailButton: UIButton!
    @IBAction func compressionDetailButton(_ sender: UIButton) { self.showCompressionDetail() }
    @IBOutlet weak var createFolderSwitch: UISwitch!
    @IBOutlet weak var deleteOnSuccessLabel: UILabel!
    @IBOutlet weak var deleteOnSuccessSwitch: UISwitch!
    @IBOutlet weak var leftPlaceholderLabel: UILabel!
    @IBOutlet weak var rightPlaceholderLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var extractButton: UIButton!
    @IBAction func extractButton(_ sender: UIButton) { self.extract() }
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: logExtractSheet, type: .debug)
        super.viewDidLoad()
        
        // Get values from parent NavigationController.
        // TODO put these in init function better?
        let parentVC = self.parent as! ExtractNavController
        self.archiveUrl = parentVC.archiveUrl
        self.reachedFromExtension = parentVC.reachedFromExtension
        
        // Default = everything disabled, label placeholders set.
        self.compressionLabel.isHidden = true
        self.compressionErrorLabel.isHidden = false
        self.createFolderSwitch.isEnabled = false
        self.createFolderSwitch.setOn(false, animated: false)
        self.deleteOnSuccessSwitch.isEnabled = false
        self.deleteOnSuccessSwitch.setOn(false, animated: false)
        self.extractButton.isEnabled = false
        self.rightPlaceholderLabel.isHidden = false
        self.activityIndicator.isHidden = true
        
        // Perform checks on file.
        if self.archiveUrl == nil {
            return
        }
        self.archiveLabel.text = self.archiveUrl!.lastPathComponent
        self.archiveType = self.getArchiveType()
        if self.archiveType != nil {
            self.compressionLabel.text = self.archiveType
            self.compressionLabel.isHidden = false
            self.compressionErrorLabel.isHidden = true
            self.compressionDetailButton.isHidden = true
            self.createFolderSwitch.isEnabled = true
            self.createFolderSwitch.setOn(true, animated: false)
            if self.reachedFromExtension == false {
                self.deleteOnSuccessSwitch.isEnabled = true
            }
            self.extractButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logExtractSheet, type: .debug)
        super.didReceiveMemoryWarning()
    }

    func getArchiveType() -> String? {
        os_log("getArchiveType", log: logExtractSheet, type: .debug)
        
        if self.archiveUrl != nil {
            if let typeIdentifier = self.archiveUrl!.typeIdentifier {
                if typeIdentifier == "public.zip-archive" { return "zip"
                } else if typeIdentifier == "public.tar-archive" { return "tar"
                } else if typeIdentifier == "org.7-zip.7-zip-archive" { return "7zip"
                // These formats don't work reliably, error if more than one file in the archive. Deactivated for now.
                // } else if typeIdentifier == "public.bzip2-archive" { return "bzip2"
                // } else if typeIdentifier == "org.tukaani.xz-archive" { return "xz"
                // } else if typeIdentifier == "org.gnu.gnu-zip-archive" { return "gzip"
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
    
    func showExtractionError(detailedError: String?) {
        os_log("showExtractionError", log: logExtractSheet, type: .debug)
        
        var msg: String = "The archive could not be extracted."
        if detailedError != nil {
            msg = detailedError!
        }
        
        let alertController = UIAlertController(title: "Error during extraction", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func extract() {
        os_log("extract", log: logExtractSheet, type: .debug)
        
        var errorMsg: String? = nil
        
        let trashArchive: Bool = self.deleteOnSuccessSwitch.isOn  // get beforehand, UI stuff not accessible async.
        self.setExtractionPending()
        self.getTargetDir()
        
        // Do the following as a background task.
        DispatchQueue.global(qos: .userInitiated).async {
            if self.archiveUrl != nil {
                self.loadData()
            }
            if self.archiveType != nil && self.targetDirUrl != nil && self.archiveData != nil {
                // These formats work. Most of the time at least.
                if ["zip", "tar", "7zip"].contains(self.archiveType!) { errorMsg = self.openContainer() }
                
                // These formats don't work reliably, error if more than one file in the archive. Deactivated for now.
                // else if ["bzip2", "xz", "gzip"].contains(self.archiveType!) { errorMsg = self.openCompression() }
            }
            self.cleanUp(error: errorMsg, trashArchive: trashArchive)
            
            // Last step.
            DispatchQueue.main.async {
                getStats()
                self.setExtractinFinished()
                
                if errorMsg == nil {
                    self.close()
                } else {
                    self.showExtractionError(detailedError: errorMsg)
                }
            }
        }
    }
    
    func setExtractionPending() {
        os_log("setExtractionPending", log: logExtractSheet, type: .debug)
        
        self.rightPlaceholderLabel.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.createFolderSwitch.isEnabled = false
        self.deleteOnSuccessSwitch.isEnabled = false
        self.extractButton.isEnabled = false
    }
    
    func setExtractinFinished() {
        os_log("setExtractinFinished", log: logExtractSheet, type: .debug)
        
        self.rightPlaceholderLabel.isHidden = false
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.createFolderSwitch.isEnabled = false
        if self.reachedFromExtension == false {
            self.deleteOnSuccessSwitch.isEnabled = true
        }
        self.extractButton.isEnabled = true
    }
    
    func getTargetDir() {
        os_log("getTargetDir", log: logExtractSheet, type: .debug)
        
        self.targetDirUrl = URL(fileURLWithPath: AppState.documentsPath, isDirectory: true)
        self.targetDirUrl?.appendPathComponent("Extracted")  // make this user selectable in a later release
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
    
    func extractFile(filename: String, filedata: Data?) {
        os_log("Found file %@.", log: logExtractSheet, type: .debug, filename)
        let targetFileUrl = self.targetDirUrl!.appendingPathComponent(filename)
        
        // Check this filename against file blacklist.
        if self.fileBlacklist.contains(targetFileUrl.lastPathComponent) {
            os_log("Skipping, filename is on blacklist.", log: logExtractSheet, type: .info)
            return
        }
        
        // Check parent folder structure against dirs blacklist.
        for dirBlacklist in self.dirsBlacklist {
            if targetFileUrl.path.range(of: dirBlacklist) != nil {
                os_log("Skipping, parent directory is on blacklist.", log: logExtractSheet, type: .info)
                return
            }
        }

        // Extract data.
        if filedata != nil {
            os_log("Writing data to %@.", log: logExtractSheet, type: .info, targetFileUrl.path)
            makeDirs(path: targetFileUrl.deletingLastPathComponent().path)
            do {
                try filedata!.write(to: targetFileUrl, options: Data.WritingOptions.atomic)
            }
            catch {
                os_log("%@", log: logExtractSheet, type: .error, error.localizedDescription)
            }
        } else {
            os_log("No data contained.", log: logExtractSheet, type: .error)
        }
    }
    
    func openContainer() -> String? {
        os_log("openContainer", log: logExtractSheet, type: .debug)
        
        // Only attempt extraction if entry is a file (=regular), entry.data is nil for directories.
        // Since directories are not reliably encountered before their contained files just skip over them.
        // Instead examine the partial file path in myZipEntryInfo.name and make sure the dirs exist.
        // No real way to soft and hard links and other advanced stuff on iOS.
        
        do {
            if self.archiveType == "zip" {
                let zipContainer = try ZipContainer.open(container: self.archiveData!)
                for zipEntry in zipContainer {
                    if zipEntry.info.type == .regular {
                        self.extractFile(filename: zipEntry.info.name, filedata: zipEntry.data)
                    }
                }
            } else if self.archiveType == "tar" {
                let tarContainer = try TarContainer.open(container: self.archiveData!)
                for tarEntry in tarContainer {
                    if tarEntry.info.type == .regular {
                        self.extractFile(filename: tarEntry.info.name, filedata: tarEntry.data)
                    }
                }
            } else if self.archiveType == "7zip" {
                let sevenZipContainer = try SevenZipContainer.open(container: self.archiveData!)
                for sevenZipEntry in sevenZipContainer {
                    if sevenZipEntry.info.type == .regular {
                        self.extractFile(filename: sevenZipEntry.info.name, filedata: sevenZipEntry.data)
                    }
                }
            }
        } catch let error as ZipError {
            os_log("ZipError %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error as TarError {
            os_log("TarError %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error as SevenZipError {
            os_log("SevenZipError %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error {
            os_log("Error %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        }
        return nil
    }
    
    func openCompression() -> String? {
        os_log("openCompression", log: logExtractSheet, type: .debug)
        
        // These are the weirders. If don't contain file info (like names or paths) but the pure file data.
        // The reason behind it is that it's implemented as a compression algorithm in my library, not a file format.
        // It can be created from within Keka on macOS though. Probably an edge case anyways.
        // I'm probably doing something wrong here. But this works for single files at least...
        
        do {
            if self.archiveType == "bzip2" {
                let decompressedData = try BZip2.decompress(data: self.archiveData!)
                let filename: String = self.archiveUrl!.deletingPathExtension().lastPathComponent
                self.extractFile(filename: filename, filedata: decompressedData)
            } else if self.archiveType == "xz" {
                let decompressedData = try XZArchive.unarchive(archive: self.archiveData!)
                let filename: String = self.archiveUrl!.deletingPathExtension().lastPathComponent
                self.extractFile(filename: filename, filedata: decompressedData)
            } else if self.archiveType == "gzip" {
                let decompressedData = try GzipArchive.unarchive(archive: self.archiveData!)
                let filename: String = self.archiveUrl!.deletingPathExtension().lastPathComponent
                self.extractFile(filename: filename, filedata: decompressedData)
            }
        } catch let error as BZip2Error {
            os_log("BZip2Error %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error as XZError {
            os_log("XZError %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error as GzipError {
            os_log("GzipError %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        } catch let error {
            os_log("Error %@", log: logExtractSheet, type: .error, error.localizedDescription)
            return error.localizedDescription
        }
        return nil
    }

    func cleanUp(error: String?, trashArchive: Bool) {
        os_log("cleanUp", log: logExtractSheet, type: .debug)
        
        // Move the archive to Trash, but only if no error and the user toggled the switch.
        if error == nil && trashArchive == true {
            trashFileIfExist(path: self.archiveUrl!.path)
        }
        
        // Always remova all content in the App Group shared folder. Also stuff that might be in there previously.
        let appGroupName: String = "group.se.eberl.localstorage"
        if let destDirUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) {
            clearDir(path: destDirUrl.path)
        }
    }
}
