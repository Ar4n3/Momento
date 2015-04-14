//
//  DateTime.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 1/12/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation

class DateTime {
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    
    func getHour() -> Int {
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        return components.hour
    }
    
    func shouldGetDataFromAPI(lastUpdate: NSDate) -> Bool {
        let theHour = self.getHour()
        let toCompareDate = calendar.dateBySettingHour(theHour, minute: 0, second: 0, ofDate: lastUpdate, options: nil)
        let fromCompareDate = calendar.dateBySettingHour(theHour, minute: 0, second: 0, ofDate: date, options: nil)
        if fromCompareDate!.isEqualToDate(toCompareDate!) {
            return false
        }
        return true
    }
    
    func calculateDelayTime(lastUpdate: NSDate) -> Int {
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: lastUpdate)
        let theHour = self.getHour()
        let lastUpdateHour = components.hour
        return theHour - lastUpdateHour
    }
    
    func getDateForLastUpdate() -> NSDate {
        return calendar.dateBySettingHour(self.getHour(), minute: 0, second: 0, ofDate: date, options: nil)!
    }
    
    func displayDate() -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeZone = NSTimeZone()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        
        return dateFormatter.stringFromDate(date)
    }
    
}