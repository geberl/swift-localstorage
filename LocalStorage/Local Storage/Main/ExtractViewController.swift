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

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("ExtractViewController viewDidLoad", log: logUi, type: .debug)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
