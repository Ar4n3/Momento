//
//  DateTime.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 1/12/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation

class DateTime {
    let date = Date()
    let calendar = Calendar.current
    
    func getHour() -> Int {
        let components = calendar.component(Calendar.Component.hour, from: date)
        return components
    }
    
    func shouldGetDataFromAPI(_ lastUpdate: Date) -> Bool {
        let theHour = self.getHour()
        let toCompareDate = calendar.date(bySettingHour: theHour, minute: 0, second: 0, of: lastUpdate, matchingPolicy: Calendar.MatchingPolicy.strict, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)
        let fromCompareDate = calendar.date(bySettingHour: theHour, minute: 0, second: 0, of: date, matchingPolicy: Calendar.MatchingPolicy.strict, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)
        if fromCompareDate == toCompareDate {
            return false
        }
        return true
    }
    
    func calculateDelayTime(_ lastUpdate: Date) -> Int {
        let components = calendar.component(Calendar.Component.hour, from: lastUpdate)
        let theHour = self.getHour()
        let lastUpdateHour = components
        return theHour - lastUpdateHour
    }
    
    func getDateForLastUpdate() -> Date {
        return calendar.date(bySettingHour: self.getHour(), minute: 0, second: 0, of: date, matchingPolicy: Calendar.MatchingPolicy.strict, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.forward)!
    }
    
    func displayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd/mm/yyyy"
        
        return dateFormatter.string(from: date)
    }
    
}
