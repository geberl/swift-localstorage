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
    
    @IBOutlet var typesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        self.setTheme()
        
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

        // let fgColor: UIColor = UIColor(named: fg)!
        let bgColor: UIColor = UIColor(named: bg)!
        
        self.mainView.backgroundColor = bgColor
    }
    
    func setDataCount() {
        let allSizes: Array = AppState.types.map { $0 .size }
        let sumSize: Double = Double(allSizes.reduce(0, +))
        let allSizesPercent: Array = allSizes.map { (Double($0) / sumSize) * 100 }
        
        let typesVals = [BarChartDataEntry(x: Double(10), yValues: allSizesPercent)]
        
        let typesSet = BarChartDataSet(values: typesVals, label: "")
        typesSet.drawIconsEnabled = false
        
        typesSet.colors = AppState.types.map { $0 .color }
        typesSet.stackLabels = AppState.types.map { $0 .name }
        
        let data = BarChartData(dataSet: typesSet)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 9.0
        
        chartView.data = data
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppState.types.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        
        cell.textLabel?.text = AppState.types[indexPath.row].name
        
        let currentSize: String = getSizeString(byteCount: AppState.types[indexPath.row].size)
        let currentNumber: Int = AppState.types[indexPath.row].number
        cell.detailTextLabel?.text = currentSize + " in " + String(currentNumber) + " items"
        
        return cell
    }
    
}
