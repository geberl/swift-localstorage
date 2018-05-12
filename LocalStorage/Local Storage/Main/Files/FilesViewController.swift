//
//  FilesViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 05.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import YMTreeMap


class FilesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func onSettingsButton(_ sender: UIButton) { self.showSettings() }
    @IBOutlet var mainView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var refreshButton: UIButton!
    @IBAction func onRefreshButton() { self.refresh() }

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logTabFiles, type: .debug)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FilesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FilesViewController.updateValues),
                                               name: .updateFinished, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FilesViewController.updateValues),
                                               name: .unitChanged, object: nil)

        self.setTheme()
        
        // The following line is needed, the Storyboard connection alone is not sufficient.
        self.collectionView?.register(FilesCollectionViewCell.self, forCellWithReuseIdentifier: "FilesCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: logTabFiles, type: .debug)
        super.viewWillAppear(animated)
        
        let treeMap = YMTreeMap(withValues: AppState.files.allValues)
        treeMap.alignment = .RetinaSubPixel

        if let layout = self.collectionView.collectionViewLayout as? FilesCollectionViewLayout {
            let bounds = self.mainView?.bounds ?? .zero
            layout.rects = treeMap.tessellate(inRect: bounds)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // This fires when switching from landscape to portrait mode.
        os_log("viewWillTransition", log: logTabFiles, type: .debug)
        super.viewWillTransition(to: size, with: coordinator)

        let treeMap = YMTreeMap(withValues: AppState.files.allValues)
        if self.collectionView != nil {
            if let layout = self.collectionView.collectionViewLayout as? FilesCollectionViewLayout {
                layout.rects = treeMap.tessellate(inRect: CGRect(origin: .zero, size: size))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logTabFiles, type: .info)
        super.didReceiveMemoryWarning()
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabFiles, type: .debug)
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabFiles, type: .debug)
        let bgColor: UIColor = UIColor(named: bg)!
        self.mainView.backgroundColor = bgColor
    }
    
    func showSettings() {
        os_log("showSettings", log: logTabFiles, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }
    
    func refresh() {
        os_log("refresh", log: logTabFiles, type: .debug)
        getStats()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppState.files.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilesCell", for: indexPath)
        
        if let cell = cell as? FilesCollectionViewCell {
            let fileInfo = AppState.files.fileInfos[indexPath.item]
            cell.tintColor = self.tintColor(forType: fileInfo.type)
            cell.symbolLabel.text = fileInfo.name
            cell.valueLabel.text = getSizeString(byteCount: Int64(AppState.files.allValues[indexPath.item]))
            
            let textColor = self.textColor(forType: fileInfo.type)
            cell.symbolLabel.textColor = textColor
            cell.valueLabel.textColor = textColor
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        // Change background color when user touches cell.
        if let cell = collectionView.cellForItem(at: indexPath) as? FilesCollectionViewCell {
            cell.tintColor = UIColor.black
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        // Change background color back when user releases touch.
        if let cell = collectionView.cellForItem(at: indexPath) as? FilesCollectionViewCell {
            let fileInfo = AppState.files.fileInfos[indexPath.item]
            cell.tintColor = self.tintColor(forType: fileInfo.type)
        }
    }
    
    @objc func updateValues() {
        self.collectionView.reloadData()
    }
    
    func tintColor(forType type: String) -> UIColor {
        if type == LocalizedTypeNames.audio {
            return varyColor(baseColor: UIColor(named: "ColorTypeAudio")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else if type == LocalizedTypeNames.videos {
            return varyColor(baseColor: UIColor(named: "ColorTypeVideos")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else if type == LocalizedTypeNames.documents {
            return varyColor(baseColor: UIColor(named: "ColorTypeDocuments")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else if type == LocalizedTypeNames.images {
            return varyColor(baseColor: UIColor(named: "ColorTypeImages")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else if type == LocalizedTypeNames.code {
            return varyColor(baseColor: UIColor(named: "ColorTypeCode")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else if type == LocalizedTypeNames.archives {
            return varyColor(baseColor: UIColor(named: "ColorTypeArchives")!, percentVaryColors: 10, percentVaryAlpha: 0)
        } else {  // type == LocalizedTypeNames.other
            return varyColor(baseColor: UIColor(named: "ColorTypeOther")!, percentVaryColors: 10, percentVaryAlpha: 0)
        }
    }
    
    func textColor(forType type: String) -> UIColor {
        if type == LocalizedTypeNames.audio {
            return UIColor(named: "ColorFontGray")!
        } else if type == LocalizedTypeNames.videos {
            return UIColor(named: "ColorFontGray")!
        } else if type == LocalizedTypeNames.other {
            return UIColor(named: "ColorFontGray")!
        }
        return UIColor.white
    }
    
    func varyColor(baseColor: UIColor, percentVaryColors: Int, percentVaryAlpha: Int) -> UIColor {
        var components: [CGFloat] = baseColor.cgColor.components!
        
        for (n, component) in components.enumerated() {
            let percentValue = Int32(component * 100)
            let randomValue = Int32.random(lower: Int32(-percentVaryColors / 2), upper: Int32(percentVaryColors / 2))
            
            var percentVaried = percentValue + randomValue
            
            if percentVaried > 100 { percentVaried = 100 }
            if percentVaried < 0 { percentVaried = 0 }
            
            components[n] = CGFloat(percentVaried) / 100
        }
        
        // RGBA
        if components.count == 4 {
            return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        }
        
        // Grayscale
        if components.count == 2 {
            return UIColor(white: components[0], alpha: components[1])
        }
        
        // Unexpected: Not RGBA and not Grayscale. Can't vary this.
        return baseColor
    }

}
