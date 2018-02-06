//
//  HashFunctionDetailViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 06.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log

class HashFunctionDetailViewController: UITableViewController {
    
    let userDefaults = UserDefaults.standard
    let hashFunctions = [
        0: ["name": "CRC32", "desc": "32 bits, Cyclic Redundancy Check"],
        1: ["name": "MD5", "desc": "128 bits, Merkle–Damgård construction"],
        2: ["name": "SHA256", "desc": "256 bits, Merkle–Damgård construction"]
    ]
    var selectedFunctionName: String = UserDefaultStruct.hashFunctionDefault
    
    @IBOutlet var hashFunctionDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logHashActionExtension, type: .debug)
        self.selectedFunctionName = userDefaults.string(forKey: UserDefaultStruct.hashFunction)!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hashFunctions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        
        cell.textLabel?.text = hashFunctions[indexPath.row]!["name"]!
        cell.detailTextLabel?.text = hashFunctions[indexPath.row]!["desc"]!
        
        if self.selectedFunctionName == hashFunctions[indexPath.row]!["name"]! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedFunctionName = hashFunctions[indexPath.row]!["name"]!
        tableView.reloadData()
        
        userDefaults.set(self.selectedFunctionName, forKey: UserDefaultStruct.hashFunction)
        NotificationCenter.default.post(name: .hashFunctionChanged, object: nil, userInfo: nil)
    }

}
