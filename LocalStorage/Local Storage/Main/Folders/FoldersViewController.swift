//
//  FoldersViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 05.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log


class FoldersViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    
    @IBOutlet var mainView: UIView!

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logTabFolders, type: .debug)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)

        self.setTheme()
    }
    
    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logTabFolders, type: .info)
        super.didReceiveMemoryWarning()
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabFolders, type: .debug)
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabFolders, type: .debug)
        let bgColor: UIColor = UIColor(named: bg)!
        self.mainView.backgroundColor = bgColor
    }
    
    func showSettings() {
        os_log("showSettings", log: logTabFolders, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }

}
