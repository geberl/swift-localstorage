//
//  TypeDetailViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 17.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log

class TypeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    var typeIndex: Int = -1
    @IBOutlet var mainView: UIView!
    @IBOutlet var typeDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logTabTypeDetail, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypeDetailViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        self.typeIndex = self.getTypeIndex()
        self.title = AppState.types[self.typeIndex].name
        
        self.setTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        os_log("viewWillDisappear", log: logTabTypeDetail, type: .debug)
        NotificationCenter.default.post(name: .backFromDetail, object: nil, userInfo: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        os_log("didReceiveMemoryWarning", log: logTabTypeDetail, type: .info)
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
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabTypeDetail, type: .debug)
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
        }
        self.typeDetailTableView.reloadData()  // changing text color in cells requires a data reload.
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabTypeDetail, type: .debug)
        let bgColor: UIColor = UIColor(named: bg)!
        self.mainView.backgroundColor = bgColor
        self.typeDetailTableView.backgroundColor = bgColor
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.types[self.typeIndex].number
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        
        cell.textLabel?.text = AppState.types[self.typeIndex].paths[indexPath.row]
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            cell.textLabel?.textColor = UIColor(named: "ColorFontWhite")!
        } else {
            cell.textLabel?.textColor = UIColor(named: "ColorFontBlack")!
        }
        cell.detailTextLabel?.text = getSizeString(byteCount: AppState.types[self.typeIndex].sizes[indexPath.row])
        
        // Display accessory only when in "Archives" type.
        if AppState.types[self.typeIndex].name == "Archives" {
            cell.accessoryType = .detailButton
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        os_log("accesoryButtonTappedForRowWith", log: logTabTypes, type: .debug)
        
        let sb = UIStoryboard(name: "Extract", bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: "ExtractViewController") as! ExtractViewController
        vc.setArchivePath(path: AppState.documentsPath + "/" + AppState.types[self.typeIndex].paths[indexPath.row])
        navigationController?.present(vc, animated: true, completion: nil)
    }

}
