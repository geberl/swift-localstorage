//
//  ActionViewController.swift
//  Hash
//
//  Created by Günther Eberl on 04.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import MobileCoreServices
import os.log
import CommonCryptoModule


// Logger configuration.
let logHashActionExtension = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "hash-action")


extension Data {
    public func md5() -> Data {
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_MD5(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha256() -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA256(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
}


class HashActionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var settingsTableView: UITableView!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBAction func onCalculateButton(_ sender: UIButton) { self.hashFile() }
    
    @IBOutlet weak var digestTextView: UITextView!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBAction func onCopyButton(_ sender: UIButton) { self.copyHash() }
    
    let userDefaults = UserDefaults.standard
    var fileData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ensureUserDefaults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HashActionViewController.reloadHashFunction),
                                               name: .hashFunctionChanged, object: nil)
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
               // Search for "Uniform Type Identifiers Reference" for a full list of UTIs.

                // For: All kinds of files on the file system.
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    provider.loadItem(forTypeIdentifier: "public.file-url",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.jpeg, public.tiff, public.fax, public.jpeg-2000 , public.camera-raw-image, ...
                if provider.hasItemConformingToTypeIdentifier("public.image") {
                    provider.loadItem(forTypeIdentifier: "public.image",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.video, com.apple.quicktime-movie, public.avi, public.mpeg, public.mpeg-4 , ...
                if provider.hasItemConformingToTypeIdentifier("public.movie") {
                    provider.loadItem(forTypeIdentifier: "public.movie",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
            }
        }
    }
    
    func loadFile(coding: NSSecureCoding?, error: Error!) {
        os_log("loadFile", log: logHashActionExtension, type: .debug)
        
        if error != nil {
            os_log("%@", log: logHashActionExtension, type: .error, error.localizedDescription)
            self.digestTextView.text = "Error: Unable to load file"
            return
        }
        
        if coding != nil {
            if let url = coding as? URL {
                do {
                    self.fileData = try Data(contentsOf: url)
                } catch let error {
                    os_log("%@", log: logHashActionExtension, type: .error, error.localizedDescription)
                    self.calculateButton.isEnabled = false
                    self.digestTextView.text = "Error: Unable to load file"
                }
            }
        }
    }
    
    func hashFile() {
        os_log("hashFile", log: logHashActionExtension, type: .debug)
        
        if self.fileData != nil {
            
            let hashFunction: String = userDefaults.string(forKey: UserDefaultStruct.hashFunction)!
            var hashDigest: String
            
            if hashFunction == "MD5" {
                let md5Data: Data = self.fileData!.md5()
                hashDigest = md5Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "SHA256" {
                let sha256Data: Data = self.fileData!.sha256()
                hashDigest = sha256Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "CRC32" {
                let crcObj = CRC32(data: self.fileData!)
                let crcDecimal: UInt32 = crcObj.crc
                var crcHex: String = String(crcDecimal, radix: 16)
                while crcHex.count < 8 {
                    crcHex = "0" + crcHex
                }
                hashDigest = crcHex
                
            } else {
                self.digestTextView.text = "Error: Undefined hash function"
                self.copyButton.isEnabled = false
                return
            }

            self.digestTextView.text = self.addLineBreaks(input: hashDigest)
            self.copyButton.isEnabled = true
        } else {
            self.digestTextView.text = "Error: Unable to hash file"
            self.copyButton.isEnabled = false
        }
    }
    
    func addLineBreaks(input: String) -> String {
        var result: String = ""
        
        for (n, char) in input.enumerated() {
            if n > 0 {
                if n % 16 == 0 {
                    result += "\n"
                } else if n % 4 == 0 {
                    result += " "
                }
            }
            result += String(char)
        }
        
        return result
    }
    
    func removeLineBreaks(input: String) -> String {
        var output: String
        output = input.replacingOccurrences(of: " ", with: "")
        output = output.replacingOccurrences(of: "\n", with: "")
        return output
    }
    
    func copyHash() {
        os_log("copyHash", log: logHashActionExtension, type: .debug)
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = self.removeLineBreaks(input: self.digestTextView.text)
    }

    @objc func reloadHashFunction() {
        os_log("reloadHashFunction", log: logHashActionExtension, type: .debug)
        self.digestTextView.text = ""
        self.copyButton.isEnabled = false
        self.settingsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let functionCell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        functionCell.textLabel?.text = "Hash function"
        functionCell.detailTextLabel?.text = userDefaults.string(forKey: UserDefaultStruct.hashFunction)!
        return functionCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // Since we don't do anything to the file, we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}
