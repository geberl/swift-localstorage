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
let logActionExtension = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "action")


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
}


class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                print(provider)
                
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    provider.loadItem(forTypeIdentifier: "public.file-url",
                                      options: [:],
                                      completionHandler: self.hashItem)
                }
            }
        }
    }
    
    func hashItem (coding: NSSecureCoding?, error: Error!) {
        os_log("hashItem", log: logActionExtension, type: .debug)
        
        if error != nil {
            os_log("%@", log: logActionExtension, type: .error, error.localizedDescription)
        }
        
        if coding != nil {
            if let url = coding as? URL {
                var fileData: Data
                do {
                    fileData = try Data(contentsOf: url)
                    
                    let fileMd5Data: Data = fileData.md5()
                    let hexDigest = fileMd5Data.map { String(format: "%02hhx", $0) }.joined()
                    print(hexDigest)
                    
                } catch let error {
                    os_log("%@", log: logActionExtension, type: .error, error.localizedDescription)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
