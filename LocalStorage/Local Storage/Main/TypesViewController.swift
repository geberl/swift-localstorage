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
        let bytesAudio: Double = 10
        let bytesVideo: Double = 5
        let bytesPhotos: Double = 20
        let bytesDocs: Double = 15
        let bytesOther: Double = 50
        
        let typesVals = [BarChartDataEntry(x: Double(10),
                                           yValues: [bytesAudio, bytesVideo, bytesPhotos, bytesDocs, bytesOther])]
        
        let typesSet = BarChartDataSet(values: typesVals, label: "")
        typesSet.drawIconsEnabled = false
        typesSet.colors = [UIColor(named: "ColorTypeAudio")!,
                           UIColor(named: "ColorTypeVideo")!,
                           UIColor(named: "ColorTypePhotos")!,
                           UIColor(named: "ColorTypeDocs")!,
                           UIColor(named: "ColorTypeOther")!]
        typesSet.stackLabels = ["Audio", "Video", "Photos", "Docs", "Other"]
        
        let data = BarChartData(dataSet: typesSet)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 9.0
        
        chartView.data = data
    }
    
}
