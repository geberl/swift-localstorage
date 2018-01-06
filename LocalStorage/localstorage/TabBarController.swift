//
//  TabBarController.swift
//  localstorage
//
//  Created by Günther Eberl on 06.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTheme() {
        if AppState.darkMode {
            self.tabBar.barStyle = UIBarStyle.black
        } else {
            self.tabBar.barStyle = UIBarStyle.default
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
