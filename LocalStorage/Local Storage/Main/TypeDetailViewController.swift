//
//  TypeDetailViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 17.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit

class TypeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var typeIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.typeIndex = self.getTypeIndex()
        self.title = AppState.types[self.typeIndex].name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTypeIndex() -> Int {
        let navChildViewControllers = self.navigationController!.childViewControllers
        
        for navChildViewController in navChildViewControllers {
            if let viewControllerTitle = navChildViewController.title {
                if viewControllerTitle == "Types" {
                    let TypesViewController = navChildViewController as! TypesViewController
                    let selectedRowIndex = TypesViewController.typesTableView.indexPathForSelectedRow!
                    return selectedRowIndex[1]
                }
            }
        }
        
        return -1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.types[self.typeIndex].number
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        
        cell.textLabel?.text = AppState.types[self.typeIndex].paths[indexPath.row]
        cell.detailTextLabel?.text = getSizeString(byteCount: AppState.types[self.typeIndex].sizes[indexPath.row])
        
        return cell
    }

}
