//
//  TabBarController.swift
//  localstorage
//
//  Created by Günther Eberl on 06.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        self.setTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func setTheme() {
        if userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.tabBar.barStyle = UIBarStyle.black
        } else {
            self.tabBar.barStyle = UIBarStyle.default
        }
    }

}
