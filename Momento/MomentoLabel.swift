//
//  MomentoLabel.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 9/12/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation
import UIKit

class MomentoLabel: UILabel {
    
    func initWithName(name: String) -> UILabel {
        switch name {
//        case "iconLabel":
//            configureLabel("icomoon", size: 80, align: NSTextAlignment.Right)
//        case "tempLabel":
//            configureLabel("Roboto", size: 60, align: NSTextAlignment.Left)
//        case "locationLabel", "summaryLabel":
//            configureLabel("Roboto", size: 18, align: NSTextAlignment.Center)
//        case "poweredBy":
//            configureLabel("Roboto", size: 10, align: NSTextAlignment.Center)
//        case "humidityLabel", "precProbIconLabel", "sunriseTimeIconLabel", "sunsetTimeIconLabel", "windSpeedIconLabel", "precipIntensityIconLabel":
//            configureLabel("icomoon", size: 20, align: NSTextAlignment.Center)
        default:
            configureLabel("Roboto", size: 17, align: NSTextAlignment.Center)
        }
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.setNeedsUpdateConstraints()
        
        return self
    }
    
    func configureLabel(name: String, size: CGFloat, align: NSTextAlignment) {
        self.attributedText = NSAttributedString()
        self.font = UIFont(name: name, size: size)
        self.textAlignment = align
        self.textColor = UIColor.lightTextColor()
        self.sizeToFit()
    }
    
}