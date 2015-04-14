//
//  MainView.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 22/11/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation
import UIKit

class MainView {
    var view: UIView
    var heightConstraint: CGFloat
    var superView: UIView
    var metrics: Dictionary<String, AnyObject> = [String: AnyObject]()
    var viewsDict: Dictionary<String, AnyObject> = [String: AnyObject]()
    var consDictionary: Dictionary<String, String> = [String: String]()
    var labelConsDictionary: Dictionary<String, String> = [String: String]()
    var visualFormatHMain: Array<AnyObject> = []
    var visualFormatVMain: Array<AnyObject> = []
    var visualFormatMainHeight: Array<AnyObject> = []
    var locationLabel: MomentoLabel = MomentoLabel()
    var iconLabel: MomentoLabel = MomentoLabel()
    var tempLabel: MomentoLabel = MomentoLabel()
    var hourPicker: UIPickerView = UIPickerView()
    var humidityLabel: MomentoLabel = MomentoLabel()
    var humidityIconLabel: MomentoLabel = MomentoLabel()
    var precProbLabel: MomentoLabel = MomentoLabel()
    var precProbIconLabel: MomentoLabel = MomentoLabel()
    var summaryLabel: MomentoLabel = MomentoLabel()
    var dateLabel: MomentoLabel = MomentoLabel()
    var windSpeedLabel: MomentoLabel = MomentoLabel()
    var windSpeedIconLabel: MomentoLabel = MomentoLabel()
    var precipIntensityLabel: MomentoLabel = MomentoLabel()
    var precipIntensityIconLabel: MomentoLabel = MomentoLabel()
    var sunriseTimeLabel: MomentoLabel = MomentoLabel()
    var sunriseTimeIconLabel: MomentoLabel = MomentoLabel()
    var sunsetTimeLabel: MomentoLabel = MomentoLabel()
    var sunsetTimeIconLabel: MomentoLabel = MomentoLabel()
    var poweredBy: MomentoLabel = MomentoLabel()
    
    init(view: UIView, height: CGFloat) {
        self.view = view
        self.superView = self.view.superview!
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.setNeedsUpdateConstraints()
        self.heightConstraint = height
        constructViews()
    }

    func constructViews() {
        self.locationLabel.initWithName("locationLabel")
        self.iconLabel.initWithName("iconLabel")
        self.tempLabel.initWithName("tempLabel")
        self.humidityLabel.initWithName("humidityLabel")
        self.humidityIconLabel.initWithName("humidityIconLabel")
        self.precProbLabel.initWithName("precProbLabel")
        self.precProbIconLabel.initWithName("precProbIconLabel")
        self.summaryLabel.initWithName("summaryLabel")
        self.windSpeedLabel.initWithName("windSpeedLabel")
        self.windSpeedIconLabel.initWithName("windSpeedIconLabel")
        self.precipIntensityLabel.initWithName("precipIntensityLabel")
        self.precipIntensityIconLabel.initWithName("precipIntensityIconLabel")
        self.sunriseTimeLabel.initWithName("sunriseTimeLabel")
        self.sunriseTimeIconLabel.initWithName("sunriseTimeIconLabel")
        self.sunsetTimeLabel.initWithName("sunsetTimeLabel")
        self.sunsetTimeIconLabel.initWithName("sunsetTimeIconLabel")
        self.dateLabel.initWithName("dateLabel")
        self.poweredBy.initWithName("poweredBy")
        
        constructDictionaries()
}

    func constructDictionaries() {
        //BUG you have to add to dictionary each object like this 
        //because if you do it in one line as literal dictionary indexing or building takes forever
        
        self.consDictionary["visualFormatHMain"] = "H:|-hSpacing-[mainView]-hSpacing-|"
        self.consDictionary["visualFormatVMain"] = "V:|-vSpacing-[mainView]-vSpacing-|"
        self.consDictionary["visualFormatMainHeight"] = "V:[mainView(mainViewHeight)]"

        self.labelConsDictionary["visualFormatHLocationLabel"] = "H:|-10-[locationLabel]-10-|"
        self.labelConsDictionary["visualFormatVLocationLabel"] = "V:[locationLabel]-30-[iconLabel]"
        self.labelConsDictionary["visualFormatHTempLabel"] = "H:[iconLabel]-hSpacing-[tempLabel]"
        self.labelConsDictionary["visualFormatVTempLabel"] = "V:[tempLabel]-vSpacing-[hourPicker]"
        self.labelConsDictionary["visualFormatTempLabelWidth"] = "H:[tempLabel(iconLabelWidth)]"
        self.labelConsDictionary["visualFormatHIconLabel"] = "H:[iconLabel]-hSpacing-[tempLabel]"
        self.labelConsDictionary["visualFormatVIconLabel"] = "V:[iconLabel]-vSpacing-[hourPicker]"
        self.labelConsDictionary["visualFormatIconLabelWidth"] = "H:[iconLabel(iconLabelWidth)]"
        self.labelConsDictionary["visualFormatHHourPicker"] = "H:|-hSpacing-[hourPicker]-hSpacing-|"
        self.labelConsDictionary["visualFormatVHourPicker"] = "V:[hourPicker]-10-|"
        self.labelConsDictionary["visualFormatHourPicker"] = "V:[hourPicker(100)]"
        self.labelConsDictionary["visualFormatHSunriseTimeLabel"] = "H:[sunriseTimeIconLabel]-10-[sunriseTimeLabel]"
        self.labelConsDictionary["visualFormatVSunriseTimeLabel"] = "V:[hourPicker]-20-[sunriseTimeLabel]"
        self.labelConsDictionary["visualFormatHSunriseTimeIconLabel"] = "H:|-40-[sunriseTimeIconLabel]"
        self.labelConsDictionary["visualFormatVSunriseTimeIconLabel"] = "V:[hourPicker]-20-[sunriseTimeIconLabel]"
        self.labelConsDictionary["visualFormatHSunsetTimeLabel"] = "H:[sunsetTimeLabel]-10-[sunsetTimeIconLabel]"
        self.labelConsDictionary["visualFormatVSunsetTimeLabel"] = "V:[hourPicker]-20-[sunsetTimeLabel]"
        self.labelConsDictionary["visualFormatHSunsetTimeIconLabel"] = "H:[sunsetTimeIconLabel]-40-|"
        self.labelConsDictionary["visualFormatVSunsetTimeIconLabel"] = "V:[hourPicker]-20-[sunsetTimeIconLabel]"
        self.labelConsDictionary["visualFormatHHumidityLabel"] = "H:[humidityIconLabel]-10-[humidityLabel]"
        self.labelConsDictionary["visualFormatVHumidityLabel"] = "V:[sunriseTimeLabel]-17-[humidityLabel]"
        self.labelConsDictionary["visualFormatHHumidityIconLabel"] = "H:|-40-[humidityIconLabel]"
        self.labelConsDictionary["visualFormatVHumidityIconLabel"] = "V:[sunriseTimeIconLabel]-20-[humidityIconLabel]"
        self.labelConsDictionary["visualFormatHPrecProbLabel"] = "H:[precProbLabel]-10-[precProbIconLabel]"
        self.labelConsDictionary["visualFormatVPrecProbLabel"] = "V:[sunsetTimeLabel]-17-[precProbLabel]"
        self.labelConsDictionary["visualForamtHPrecProbIconLabel"] = "H:[precProbIconLabel]-40-|"
        self.labelConsDictionary["visualFormatVPrecProbIconLabel"] = "V:[sunsetTimeIconLabel]-20-[precProbIconLabel]"
        self.labelConsDictionary["visualFormatHWindSpeedLabel"] = "H:[windSpeedIconLabel]-10-[windSpeedLabel]"
        self.labelConsDictionary["visualFormatVWindSpeedLabel"] = "V:[humidityLabel]-17-[windSpeedLabel]"
        self.labelConsDictionary["visualFormatHWindSpeedIconLabel"] = "H:|-40-[windSpeedIconLabel]"
        self.labelConsDictionary["visualFormatVWindSpeedIconLabel"] = "V:[humidityIconLabel]-20-[windSpeedIconLabel]"
        self.labelConsDictionary["visualFormatHPrecipIntensityLabel"] = "H:[precipIntensityLabel]-10-[precipIntensityIconLabel]"
        self.labelConsDictionary["visualFormatVPrecipIntensityLabel"] = "V:[precProbLabel]-17-[precipIntensityLabel]"
        self.labelConsDictionary["visualFormatHPrecipIntensityIconLabel"] = "H:[precipIntensityIconLabel]-40-|"
        self.labelConsDictionary["visualFormatVPrecipIntensityIconLabel"] = "V:[precProbIconLabel]-20-[precipIntensityIconLabel]"
        self.labelConsDictionary["visualFormatHSummaryLabel"] = "H:|-hSpacing-[summaryLabel]-hSpacing-|"
        self.labelConsDictionary["visualFormatVSummaryLabel"] = "V:[windSpeedLabel]-30-[summaryLabel]"
        self.labelConsDictionary["visualFormatHDateLabel"] = "H:|-hSpacing-[dateLabel]-hSpacing-|"
        self.labelConsDictionary["visualFormatVDateLabel"] = "V:[summaryLabel]-30-[dateLabel]"
        self.labelConsDictionary["visualFormatHPoweredBy"] = "H:[poweredBy]-10-|"
        self.labelConsDictionary["visualFormatVPowereBy"] = "V:[poweredBy]-5-|"
       
        self.metrics["vSpacing"] = 0
        self.metrics["hSpacing"] = 0
        self.metrics["mainViewHeight"] = heightConstraint
        self.metrics["mainViewWidth"] = heightConstraint
        self.metrics["iconLabelWidth"] = heightConstraint/2
        
        self.viewsDict["mainView"] = self.view
        self.viewsDict["tempLabel"] = self.tempLabel
        self.viewsDict["iconLabel"] = self.iconLabel
        self.viewsDict["locationLabel"] = self.locationLabel
        self.viewsDict["hourPicker"] = self.hourPicker
        self.viewsDict["humidityLabel"] = self.humidityLabel
        self.viewsDict["humidityIconLabel"] = self.humidityIconLabel
        self.viewsDict["precProbLabel"] = self.precProbLabel
        self.viewsDict["precProbIconLabel"] = self.precProbIconLabel
        self.viewsDict["summaryLabel"] = self.summaryLabel
        self.viewsDict["sunriseTimeLabel"] = self.sunriseTimeLabel
        self.viewsDict["sunriseTimeIconLabel"] = self.sunriseTimeIconLabel
        self.viewsDict["sunsetTimeLabel"] = self.sunsetTimeLabel
        self.viewsDict["sunsetTimeIconLabel"] = self.sunsetTimeIconLabel
        self.viewsDict["windSpeedLabel"] = self.windSpeedLabel
        self.viewsDict["windSpeedIconLabel"] = self.windSpeedIconLabel
        self.viewsDict["precipIntensityLabel"] = self.precipIntensityLabel
        self.viewsDict["precipIntensityIconLabel"] = self.precipIntensityIconLabel
        self.viewsDict["dateLabel"] = self.dateLabel
        self.viewsDict["poweredBy"] = self.poweredBy
       
        addSubviewsAndInstallConstraints(self.viewsDict)
    }

    func addSubviewsAndInstallConstraints(subviews: Dictionary<String, AnyObject>) {
        for subview in subviews {
            if subview.0 != "mainView" {
                self.view.addSubview(subview.1 as! UIView)
            }
        }
        for constraint in self.labelConsDictionary {
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraint.1 as String, options: nil, metrics: self.metrics, views: self.viewsDict))
        }
    }
    
    func installConstraints() {
        self.visualFormatHMain = NSLayoutConstraint.constraintsWithVisualFormat(self.consDictionary["visualFormatHMain"]!, options: nil, metrics: self.metrics, views: self.viewsDict)
        self.visualFormatVMain = NSLayoutConstraint.constraintsWithVisualFormat(self.consDictionary["visualFormatVMain"]!, options: nil, metrics: self.metrics, views: self.viewsDict)
        self.visualFormatMainHeight = NSLayoutConstraint.constraintsWithVisualFormat(self.consDictionary["visualFormatMainHeight"]!, options: nil, metrics: self.metrics, views: self.viewsDict)
        superView.addConstraints(visualFormatHMain)
        superView.addConstraints(visualFormatVMain)
        superView.addConstraints(visualFormatMainHeight)
    }
}
