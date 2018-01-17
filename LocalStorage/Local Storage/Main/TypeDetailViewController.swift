//
//  TypeDetailViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 17.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class TypeDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.getTitle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTitle() -> String {
        let navChildViewControllers = self.navigationController!.childViewControllers  // [TypesViewController, TypeDetailViewController]
        
        for navChildViewController in navChildViewControllers {
            if let viewControllerTitle = navChildViewController.title {
                if viewControllerTitle == "Types" {
                    let TypesViewController = navChildViewController as! TypesViewController
                    let selectedRowIndex = TypesViewController.typesTableView.indexPathForSelectedRow!
                    return AppState.types[selectedRowIndex[1]].name
                }
            }
        }
        
        return "n/a"  // this should never happen.
    }

}
