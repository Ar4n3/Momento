//
//  WeatherDataToday.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 22/11/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation
import CoreData

class WeatherDataToday: NSManagedObject {

    @NSManaged var jsonData: NSData
    @NSManaged var dateStored: NSDate
    @NSManaged var coordString: String
    
    class func saveInManagedObjectContext(moc: NSManagedObjectContext, lastUpdate: NSDate, data: NSData, coordString: String) {
        var error: NSError?
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("WeatherDataToday", inManagedObjectContext: moc) as! WeatherDataToday
        newItem.dateStored = lastUpdate
        newItem.jsonData = data
        newItem.coordString = coordString
        if moc.save(&error) {
            println(error?.localizedDescription)
        }
    }
    
    class func isEmpty(moc: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "WeatherDataToday")
        if let result = moc.executeFetchRequest(fetchRequest, error: nil) as! [WeatherDataToday]? {
            if result.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    class func fetchDataInManagedObjectContext(moc: NSManagedObjectContext) -> WeatherDataToday {
        let fetchRequest = NSFetchRequest(entityName: "WeatherDataToday")
        let result = moc.executeFetchRequest(fetchRequest, error: nil) as! [WeatherDataToday]
        
        return result[0] as WeatherDataToday
    }
    
    class func updateInManagedObjectContext(moc: NSManagedObjectContext, lastUpdate: NSDate, data: NSData, coordString: String) {
        let updateItem = WeatherDataToday.fetchDataInManagedObjectContext(moc)
        updateItem.setValue(lastUpdate, forKey: "dateStored")
        updateItem.setValue(data, forKey: "jsonData")
        updateItem.setValue(coordString, forKey: "coordString")
    }
}