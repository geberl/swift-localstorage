//
//  TypesViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 07.01.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import Charts
import UIKit
import os.log

class TypesViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func onSettingsButton(_ sender: UIButton) {
        self.showSettings()
    }
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var chartView: HorizontalBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        self.setTheme()
        
        // Data stuff below (temporary)
        print(AppState.typeSizeAudio)
        print(AppState.typeSizeVideos)
        print(AppState.typeSizeDocuments)
        print(AppState.typeSizeImages)
        print(AppState.typeSizeCode)
        print(AppState.typeSizeArchives)
        print(AppState.typeSizeOther)
        print("---")
        print(AppState.typeNumberAudio)
        print(AppState.typeNumberVideos)
        print(AppState.typeNumberDocuments)
        print(AppState.typeNumberImages)
        print(AppState.typeNumberCode)
        print(AppState.typeNumberArchives)
        print(AppState.typeNumberOther)
        
        // Chart stuff below
        
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 1
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.granularity = 10
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.axisLineColor = UIColor(named: "ColorFontGray")!
        leftAxis.labelTextColor = UIColor(named: "ColorFontGray")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 8
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = UIColor(named: "ColorFontGray")!
        l.xEntrySpace = 10
        
        chartView.fitBars = true
        
        if userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh) {
            chartView.animate(yAxisDuration: 1.5)
        } else {
            chartView.animate(yAxisDuration: 0)
        }

        self.setDataCount()
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
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logGeneral, type: .debug)
        if userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logGeneral, type: .debug)

        let fgColor: UIColor = UIColor(named: fg)!
        let bgColor: UIColor = UIColor(named: bg)!
        
        self.mainView.backgroundColor = bgColor
    }
    
    func setDataCount() {
        let bytesTotal: Double = Double(AppState.typeSizeAudio) + Double(AppState.typeSizeVideos) + Double(AppState.typeSizeImages) + Double(AppState.typeSizeDocuments) + Double(AppState.typeSizeCode) + Double(AppState.typeSizeArchives) + Double(AppState.typeSizeOther)
        
        let bytesAudio:     Double = (Double(AppState.typeSizeAudio) / bytesTotal) * 100
        let bytesVideos:    Double = (Double(AppState.typeSizeVideos) / bytesTotal) * 100
        let bytesImages:    Double = (Double(AppState.typeSizeImages) / bytesTotal) * 100
        let bytesDocuments: Double = (Double(AppState.typeSizeDocuments) / bytesTotal) * 100
        let bytesCode:      Double = (Double(AppState.typeSizeCode) / bytesTotal) * 100
        let bytesArchives:  Double = (Double(AppState.typeSizeArchives) / bytesTotal) * 100
        let bytesOther:     Double = (Double(AppState.typeSizeOther) / bytesTotal) * 100
        
        print("---")
        print("Total " + String(bytesTotal) + " bytes")
        print("Audio " + String(bytesAudio) + " %")
        print("Video " + String(bytesVideos) + " %")
        print("Images " + String(bytesImages) + " %")
        print("Docs " + String(bytesDocuments) + " %")
        print("Code " + String(bytesCode) + " %")
        print("Archives " + String(bytesArchives) + " %")
        print("Other " + String(bytesOther) + " %")
        
        let typesVals = [BarChartDataEntry(x: Double(10),
                                           yValues: [bytesAudio, bytesVideos, bytesImages, bytesDocuments, bytesCode, bytesArchives, bytesOther])]
        
        let typesSet = BarChartDataSet(values: typesVals, label: "")
        typesSet.drawIconsEnabled = false
        typesSet.colors = [UIColor(named: "ColorTypeAudio")!,
                           UIColor(named: "ColorTypeVideos")!,
                           UIColor(named: "ColorTypeDocuments")!,
                           UIColor(named: "ColorTypeImages")!,
                           UIColor(named: "ColorTypeCode")!,
                           UIColor(named: "ColorTypeArchives")!,
                           UIColor(named: "ColorTypeOther")!]
        typesSet.stackLabels = ["Audio", "Videos", "Documents", "Images", "Code", "Archives", "Other"]
        
        let data = BarChartData(dataSet: typesSet)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 9.0
        
        chartView.data = data
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.types.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allTypes: Array = Array(AppState.types.keys.sorted())
        let currentType: String = allTypes[indexPath.row]
        let currentName: String = AppState.types[currentType]!.name
        let currentSize: Int64 = AppState.types[currentType]!.size
        let currentNumber: Int64 = AppState.types[currentType]!.number
        
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "protoCell")
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.text = currentName
        cell.detailTextLabel?.text = String(currentSize) + " bytes in " + String(currentNumber) + " files"
        
        return cell
    }
    
}
