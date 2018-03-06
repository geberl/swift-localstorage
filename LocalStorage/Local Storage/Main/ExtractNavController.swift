//
//  ExtractNavController.swift
//  localstorage
//
//  Created by Günther Eberl on 06.03.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log


class ExtractNavController: UINavigationController {
    
    var archiveUrl: URL? = nil
    var reachedFromExtension: Bool = false
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: logExtractSheet, type: .debug)
        super.viewDidLoad()
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

}
