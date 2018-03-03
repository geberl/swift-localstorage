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
    
    var archivePath: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logUi, type: .debug)
        
        self.fileLabel.text = "File: " + self.archivePath!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var fileLabel: UILabel!
    
    func setArchivePath(path: String) {
        os_log("setArchivePath", log: logUi, type: .debug)
        self.archivePath = path
    }
}
