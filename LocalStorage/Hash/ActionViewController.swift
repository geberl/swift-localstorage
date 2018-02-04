//
//  ActionViewController.swift
//  Hash
//
//  Created by Günther Eberl on 04.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import MobileCoreServices

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
        print("hashItem")
        
        if coding != nil {
            print(coding!)
            
            if let url = coding as? URL {
                print(url)
                print(url.path)
            }
        }
        
        if error != nil {
            print(error)
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
