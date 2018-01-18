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
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var chartView: HorizontalBarChartView!
    @IBOutlet var typesTableView: UITableView!
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}

    @IBOutlet var refreshButton: UIButton!
    @IBAction func onRefreshButton() {self.refresh()}

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad", log: logGeneral, type: .debug)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updatePending),
                                               name: .updatePending, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updateValues),
                                               name: .updateFinished, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updateValues),
                                               name: .unitChanged, object: nil)
        
        self.setTheme()
        self.setupChart()
        
        if AppState.updateInProgress {
            self.updatePending()
        }
        
        self.updateGraph()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        os_log("didReceiveMemoryWarning", log: logGeneral, type: .info)
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
    
    func showSettings() {
        os_log("showSettings", log: logUi, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }
    
    func refresh() {
        os_log("refresh", log: logUi, type: .debug)
        getStats()
    }
    
    func setupChart() {
        self.chartView.chartDescription?.enabled = false
        self.chartView.dragEnabled = false
        self.chartView.setScaleEnabled(true)
        self.chartView.pinchZoomEnabled = false
        self.chartView.rightAxis.enabled = false
        self.chartView.delegate = self
        self.chartView.drawBarShadowEnabled = false
        self.chartView.drawValueAboveBarEnabled = false
        self.chartView.maxVisibleCount = 1
        
        let xAxis = self.chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.granularity = 10
        
        let leftAxis = self.chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.axisLineColor = UIColor(named: "ColorFontGray")!
        leftAxis.labelTextColor = UIColor(named: "ColorFontGray")!
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        
        let l = self.chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 8
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = UIColor(named: "ColorFontGray")!
        l.xEntrySpace = 10
        
        self.chartView.fitBars = true
        
        if userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh) {
            self.chartView.animate(yAxisDuration: 1.5)
        } else {
            self.chartView.animate(yAxisDuration: 0)
        }
    }
    
    @objc func updatePending() {
        os_log("updatePending", log: logGeneral, type: .debug)
        
        // TODO unclear what shows if this takes longer (copy 1000s of log files to iPad again)
    }
    
    @objc func updateValues() {
        self.updateGraph()
        self.typesTableView.reloadData()
    }
    
    func updateGraph() {
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
        
        self.chartView.data = data
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
