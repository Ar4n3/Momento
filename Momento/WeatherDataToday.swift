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

    @NSManaged var jsonData: Data
    @NSManaged var dateStored: Date
    @NSManaged var coordString: String
    
    class func saveInManagedObjectContext(_ moc: NSManagedObjectContext, lastUpdate: Date, data: Data, coordString: String) {
        var _: NSError?
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "WeatherDataToday", into: moc) as! WeatherDataToday
        newItem.dateStored = lastUpdate
        newItem.jsonData = data
        newItem.coordString = coordString
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
        }
    }
    
    class func isEmpty(_ moc: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<WeatherDataToday>(entityName: "WeatherDataToday")
        let result = try? moc.fetch(fetchRequest)
        if (result?.count)! > 0 {
            return false
        } else {
            return true
        }
    }
    
    class func fetchDataInManagedObjectContext(_ moc: NSManagedObjectContext) -> WeatherDataToday? {
        let fetchRequest = NSFetchRequest<WeatherDataToday>(entityName: "WeatherDataToday")
        if let result = try? moc.fetch(fetchRequest) {
            return result[0]
        }
        return nil
    }
    
    class func updateInManagedObjectContext(_ moc: NSManagedObjectContext, lastUpdate: Date, data: Data, coordString: String) {
        if let updateItem = WeatherDataToday.fetchDataInManagedObjectContext(moc) {
            updateItem.setValue(lastUpdate, forKey: "dateStored")
            updateItem.setValue(data, forKey: "jsonData")
            updateItem.setValue(coordString, forKey: "coordString")
        }
    }
}
