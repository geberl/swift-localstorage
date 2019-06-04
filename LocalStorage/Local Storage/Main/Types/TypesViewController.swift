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
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}

    @IBOutlet var mainView: UIView!
    @IBOutlet var chartView: HorizontalBarChartView!
    @IBOutlet var typesTableView: UITableView!

    @IBOutlet var refreshButton: UIButton!
    @IBAction func onRefreshButton() {self.refresh()}
    
    var animateUpdateDuringRefresh: Bool = false
    
    override func viewDidLoad() {
        os_log("viewDidLoad", log: logTabTypes, type: .debug)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updatePending),
                                               name: .updatePending, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updateValues),
                                               name: .updateItemAdded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updateValues),
                                               name: .updateFinished, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.updateValues),
                                               name: .unitChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.deselectRow),
                                               name: .backFromDetail, object: nil)
        
        self.animateUpdateDuringRefresh = self.userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh)
        
        self.setTheme()
        self.setupChart()
        
        if AppState.updateInProgress {
            self.updatePending()
        } else {
            self.updateValues()
        }
    }

    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logTabTypes, type: .info)
        super.didReceiveMemoryWarning()
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabTypes, type: .debug)
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
        self.typesTableView.reloadData()  // changing text color in cells requires a data reload.
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabTypes, type: .debug)
        let bgColor: UIColor = UIColor(named: bg)!
        self.mainView.backgroundColor = bgColor
        self.typesTableView.backgroundColor = bgColor
    }
    
    func showSettings() {
        os_log("showSettings", log: logTabTypes, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }
    
    func refresh() {
        os_log("refresh", log: logTabTypes, type: .debug)
        self.animateUpdateDuringRefresh = self.userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh)
        getStats()
    }
    
    func setupChart() {
        self.chartView.chartDescription?.enabled = false
        self.chartView.dragEnabled = false
        self.chartView.isUserInteractionEnabled = false
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
        
        // TODO remove this workaround for Charts tallness/legend issue after upgrade 3.0.5 -> 3.1.1
        // https://github.com/danielgindi/Charts/issues/3359 (commented)
        self.chartView.extraBottomOffset = CGFloat(32)
        
        if userDefaults.bool(forKey: UserDefaultStruct.animateUpdateDuringRefresh) {
            self.chartView.animate(yAxisDuration: 1.5)
        } else {
            self.chartView.animate(yAxisDuration: 0)
        }
    }
    
    @objc func updatePending() {
        os_log("updatePending", log: logTabTypes, type: .debug)
        self.updateGraphPending()
        self.typesTableView.reloadData()
    }
    
    @objc func updateValues() {
        self.updateGraph()
        self.typesTableView.reloadData()
    }
    
    func updateGraphPending() {
        let data: BarChartData
        
        let typesVals = [BarChartDataEntry(x: Double(10), yValues: [100])]
        
        let typesSet = BarChartDataSet(entries: typesVals, label: "")
        typesSet.drawIconsEnabled = false
        typesSet.colors = [UIColor(named: "ColorTypeOther")!]
        typesSet.stackLabels = ["Refreshing"]  // only shows up if two or more values
        
        data = BarChartData(dataSet: typesSet)
        
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 9.0
        
        self.chartView.data = data
    }
    
    func updateGraph() {
        let data: BarChartData

        let allSizes: Array = AppState.types.map { $0 .size }
        let sumSize: Double = Double(allSizes.reduce(0, +))
        let allSizesPercent: Array = allSizes.map { (Double($0) / sumSize) * 100 }
        
        let typesVals = [BarChartDataEntry(x: Double(10), yValues: allSizesPercent)]
        
        let typesSet = BarChartDataSet(entries: typesVals, label: "")
        typesSet.drawIconsEnabled = false
        
        typesSet.colors = AppState.types.map { $0 .color }
        typesSet.stackLabels = AppState.types.map { $0 .name }
        
        data = BarChartData(dataSet: typesSet)
        
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
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            cell.textLabel?.textColor = UIColor(named: "ColorFontWhite")!
        } else {
            cell.textLabel?.textColor = UIColor(named: "ColorFontBlack")!
        }
        
        if AppState.updateInProgress && !self.animateUpdateDuringRefresh {
            cell.detailTextLabel?.text = "..."
            return cell
        }

        let currentSize: String = getSizeString(byteCount: AppState.types[indexPath.row].size)
        let currentNumber: Int = AppState.types[indexPath.row].number
        
        let cellLabelIn = NSLocalizedString("cell-label-in",
                                           value: "in",
                                           comment: "The 'in' in '56 bytes in 7 items'.")
        
        let cellLabelItems = NSLocalizedString("cell-label-items",
                                               value: "items",
                                               comment: "The 'items' in '56 bytes in 7 items'.")
        
        cell.detailTextLabel?.text = currentSize + " " + cellLabelIn + " " + String(currentNumber) + " " + cellLabelItems
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    @objc func deselectRow() {
        let selectedRow = self.typesTableView.indexPathForSelectedRow
        if selectedRow != nil {
            self.typesTableView.deselectRow(at: selectedRow!, animated: true)
        }
    }
    
}
