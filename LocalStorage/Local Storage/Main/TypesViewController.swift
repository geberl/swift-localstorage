//
//  TypesViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log

class TypesViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard

    @IBOutlet var parentUiView: UIView!
    @IBOutlet var headlineLabel: UILabel!
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        self.setTheme()
        
        // print(AppState.typeSizes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showSettings() {
        os_log("showSettings", log: logUi, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: false, completion: nil)
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logGeneral, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logGeneral, type: .debug)

        let fgColor: UIColor = UIColor(named: fg)!
        let bgColor: UIColor = UIColor(named: bg)!
        
        parentUiView.backgroundColor = bgColor
        
        headlineLabel.textColor = fgColor
    }
    
}
