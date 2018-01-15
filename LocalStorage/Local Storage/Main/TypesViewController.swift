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

class TypesViewController: UIViewController, ChartViewDelegate {
    
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
        
        // data stuff below
        //print(AppState.typeSizes)
        
        // chart stuff below
        
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.granularity = 10
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.axisMinimum = 0
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 8
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 10
        
        chartView.fitBars = true
        
        chartView.animate(yAxisDuration: 2.0)
        
        self.setDataCount(Int(4), range: UInt32(50))
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
    
    func setDataCount(_ count: Int, range: UInt32) {
        let spaceForBar = 10.0
        
        let yVals = (0..<count).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            return BarChartDataEntry(x: Double(i) * spaceForBar, y: val)
        }
        
        let set1 = BarChartDataSet(values: yVals, label: "Set1")
        set1.drawIconsEnabled = false
        
        let audioVals = [BarChartDataEntry(x: Double(4) * spaceForBar, y: 5),
                         BarChartDataEntry(x: Double(5) * spaceForBar, y: 10)]
    
        let audioSet = BarChartDataSet(values: audioVals, label: "Audio")
        audioSet.drawIconsEnabled = false
        audioSet.colors = [NSUIColor.red]
        
        let videoVals = [BarChartDataEntry(x: Double(6) * spaceForBar, yValues: [10, 40]),
                         BarChartDataEntry(x: Double(7) * spaceForBar, yValues: [20, 40])]
        
        let videoSet = BarChartDataSet(values: videoVals, label: "Video")
        videoSet.drawIconsEnabled = false
        videoSet.colors = [NSUIColor.green, NSUIColor.blue]
        videoSet.stackLabels = ["abc", "def"]
        
        let data = BarChartData(dataSets: [set1, audioSet, videoSet])
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 9.0
        
        chartView.data = data
    }
    
}
