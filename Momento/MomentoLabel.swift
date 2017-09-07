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
    
    func initWithName(_ name: String) -> MomentoLabel {
        switch name {
        case "iconLabel":
            configureLabel("icomoon", size: 80, align: NSTextAlignment.right)
        case "tempLabel":
            configureLabel("Roboto", size: 60, align: NSTextAlignment.left)
        case "locationLabel", "summaryLabel":
            configureLabel("Roboto", size: 18, align: NSTextAlignment.center)
        case "poweredBy":
            configureLabel("Roboto", size: 10, align: NSTextAlignment.center)
        case "humidityIconLabel", "precProbIconLabel", "sunriseTimeIconLabel", "sunsetTimeIconLabel", "windSpeedIconLabel", "precipIntensityIconLabel":
            configureLabel("icomoon", size: 20, align: NSTextAlignment.center)
        default:
            configureLabel("Roboto", size: 17, align: NSTextAlignment.center)
        }
        self.setNeedsUpdateConstraints()
        
        return self
    }
    
    func configureLabel(_ name: String, size: CGFloat, align: NSTextAlignment) {
        self.attributedText = NSAttributedString()
        self.font = UIFont(name: name, size: size)
        self.textAlignment = align
        self.textColor = UIColor.lightText
        self.sizeToFit()
    }
    
}
