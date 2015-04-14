//
//  Current.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 22/11/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

struct Current {
    var currentLocation: String?
    var currentCoordenates: String?
    var lastUpdate: NSDate?
    var temperature: Int
    var humidity: Double
    var precipProbability: Double
    var summary: String
    var icon: String?
    var windSpeed: Double
    var precipIntensity: String
    var sunriseTime: String?
    var sunsetTime: String?
    var hourly: Array<NSDictionary>?
    
    init(weatherDictionary: NSDictionary) {
        let currentWeather = weatherDictionary["currently"] as! NSDictionary
        let dailyWeather = weatherDictionary["daily"] as! NSDictionary
        var dailyWeatherToday: NSDictionary!
        for dailyWeatherData in dailyWeather {
            if dailyWeatherData.key as! String == "data" {
                dailyWeatherToday = dailyWeatherData.value[0] as! NSDictionary
            }
        }
        
        for dataDictionary in weatherDictionary["hourly"] as! NSDictionary {
            if (dataDictionary.key as! String == "data") {
                hourly = dataDictionary.value as? Array
            }
        }
        temperature = Int(round(currentWeather["temperature"] as! Double))
        humidity = currentWeather["humidity"] as! Double
        precipProbability = currentWeather["precipProbability"] as! Double
        summary = currentWeather["summary"] as! String
        windSpeed = currentWeather["windSpeed"] as! Double
        precipIntensity = (currentWeather["precipIntensity"] as! Double).format(".2")
        
        let iconString = currentWeather["icon"] as! String
        icon = weatherIconFromString(iconString)
        
        let sunriseTimeIntValue = dailyWeatherToday["sunriseTime"] as! Int
        sunriseTime = dateStringFromUnixTime(sunriseTimeIntValue)
        
        let sunsetTimeIntValue = dailyWeatherToday["sunsetTime"] as! Int
        sunsetTime = dateStringFromUnixTime(sunsetTimeIntValue)
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func weatherIconFromString(stringIcon: String) -> String {
        var imageName: String
        
        switch stringIcon {
//        case "clear-day":
//            imageName = "ClearDay"
//        case "clear-night":
//            imageName = "ClearNight"
//        case "rain":
//            imageName = "Rainy"
//        case "snow":
//            imageName = "Snowy"
//        case "sleet":
//            imageName = "Sleet"
//        case "wind":
//            imageName = "Windy"
//        case "fog":
//            imageName = "Fog"
//        case "cloudy":
//            imageName = "Cloudy"
//        case "partly-cloudy-day":
//            imageName = "PartlyCloudyDay"
//        case "partly-cloudy-night":
//            imageName = "PartlyCloudyNight"
        default:
            imageName = "Default"
        }
        
        return imageName
    }
    
    func getDataFromGivenHour(hour: NSTimeInterval) -> AnyObject {
        var givenHourDictionary: NSDictionary?
        for hourDictionary in hourly! {
            if (hourDictionary["time"] as! NSTimeInterval == hour) {
                givenHourDictionary = hourDictionary
            }
        }
        if (givenHourDictionary == nil) {
            return false
        }
        
        return givenHourDictionary!
    }
    
}