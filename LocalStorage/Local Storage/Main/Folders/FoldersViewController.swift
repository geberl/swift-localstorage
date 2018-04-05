//
//  FoldersViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 05.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import YMTreeMap


class FoldersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let userDefaults = UserDefaults.standard
    let values = TestValues_Dow30.AllValues  // TODO use user's filesystem values, not stock test values.
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    @IBOutlet var mainView: UIView!
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logTabFolders, type: .debug)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)

        self.setTheme()
        
        // The following line is needed, the Storyboard connection alone is not sufficient.
        self.collectionView?.register(FoldersCollectionViewCell.self, forCellWithReuseIdentifier: "FolderCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: logTabFolders, type: .debug)
        super.viewWillAppear(animated)
        
        let treeMap = YMTreeMap(withValues: self.values)
        treeMap.alignment = .RetinaSubPixel

        if let layout = self.collectionView.collectionViewLayout as? FoldersCollectionViewLayout {
            let bounds = self.mainView?.bounds ?? .zero
            layout.rects = treeMap.tessellate(inRect: bounds)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // This fires when switching from landscape to portrait mode.
        os_log("viewWillTransition", log: logTabFolders, type: .debug)
        super.viewWillTransition(to: size, with: coordinator)

        let treeMap = YMTreeMap(withValues: self.values)
        if let layout = self.collectionView.collectionViewLayout as? FoldersCollectionViewLayout {
            layout.rects = treeMap.tessellate(inRect: CGRect(origin: .zero, size: size))
        }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath)
        
        if let cell = cell as? FoldersCollectionViewCell {
            let company = TestValues_Dow30.Companies[indexPath.item]
            let color = self.color(forValue: company.percentChange)
            
            cell.tintColor = color
            cell.symbolLabel.text = company.symbol
            cell.valueLabel.text = String(format: "%+.2f%%", company.percentChange)
        }
        return cell
    }
    
    func color(forValue value: Double) -> UIColor {
        var previousBucketCutoff = Double.greatestFiniteMagnitude;
        var colors = TestValues_Dow30.colors
        var (nextBucketCutoff, color) = colors.removeFirst()
        
        while !colors.isEmpty {
            let bucketCutoff = nextBucketCutoff
            let currentColor = color
            (nextBucketCutoff, color) = colors.removeFirst()
            
            if value < 0 { // negative
                if value >= bucketCutoff && value < nextBucketCutoff {
                    return currentColor
                }
            }
            else { // positive
                if value <= bucketCutoff && value > previousBucketCutoff {
                    return currentColor
                } else if value <= nextBucketCutoff && value > bucketCutoff {
                    return color
                }
            }
            
            previousBucketCutoff = bucketCutoff
        }
        
        return UIColor.white
    }

}
