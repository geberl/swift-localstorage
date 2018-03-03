//
//  ExtractViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 01.03.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log


class ExtractViewController: UIViewController {
    
    var archiveUrl: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logUi, type: .debug)
        
        if self.archiveUrl != nil {
            self.fileLabel.text = "File: " + (self.archiveUrl?.lastPathComponent)!
            self.extractButton.isEnabled = true
        } else {
            self.extractButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var fileLabel: UILabel!
    
    @IBOutlet weak var extractButton: UIButton!
    
    @IBAction func onExtractButton(_ sender: UIButton) {
        os_log("onExtractButton", log: logUi, type: .debug)
    }
    
    func setArchiveUrl(path: String) {
        os_log("setArchiveUrl", log: logUi, type: .debug)
        self.archiveUrl = URL(string: path)
    }
}
