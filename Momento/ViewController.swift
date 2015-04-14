//
//  ViewController.swift
//  Momento
//
//  Created by Enara Lopez Otaegi on 22/11/14.
//  Copyright (c) 2014 Enara Lopez Otaegi. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    //MARK: - Vars and constants
    private let apiKey = "1230094637b31f01c8bfaddb0587a4bc"
    
    var mainView: MainView!
    let colorWheel = ColorWheel()
    var pickerData = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    var currentWeather: Current!
    var newTodayWeatherStored: WeatherDataToday!
    var dateTime: DateTime!
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    let locationManager: CLLocationManager = CLLocationManager()
    
    //MARK: -Override funcs
    override func loadView() {
        let applicationFrame: CGRect = UIScreen.mainScreen().bounds
        let contentView: UIView = UIView(frame: applicationFrame)
        contentView.backgroundColor = colorWheel.randomColor()
        
        view = contentView
        
        var principalView = UIView()
        var otherView = UIView()
        view.addSubview(principalView)
        view.addSubview(otherView)
        mainView = MainView(view: principalView, height: applicationFrame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTime = DateTime()
        mainView.installConstraints()
        mainView.hourPicker.dataSource = self
        mainView.hourPicker.delegate = self
        setPickerData()
        if WeatherDataToday.isEmpty(managedObjectContext!) {
            loadPlaceholder()
        } else {
            fetchDataFromCore()
        }
        startLocationManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Helper Funcs
    //MARK: Loading Data
    func setPickerData() {
        for var i = dateTime.getHour(); i > 0; --i {
            pickerData.removeAtIndex(i-1)
        }
    }
    
    func loadPlaceholder() {
        mainView.tempLabel.text = "--º"
        mainView.locationLabel.text = "Location"
    }
    
    func loadData() {
        mainView.poweredBy.text = "Powered by Forecast"
        mainView.tempLabel.text = "\(currentWeather.temperature)º"
        switch currentWeather.icon! {
        case "ClearDay":
            mainView.iconLabel.text = String(format: "%C", Weather.ClearDay.rawValue)
        case "ClearNight":
            mainView.iconLabel.text = String(format: "%C", Weather.ClearNight.rawValue)
        case "Rainy":
            mainView.iconLabel.text = String(format: "%C", Weather.Rainy.rawValue)
        case "Snowy":
            mainView.iconLabel.text = String(format: "%C", Weather.Snowy.rawValue)
        case "Sleet":
            mainView.iconLabel.text = String(format: "%C", Weather.Sleet.rawValue)
        case "Windy":
            mainView.iconLabel.text = String(format: "%C", Weather.Windy.rawValue)
        case "Fog":
            mainView.iconLabel.text = String(format: "%C", Weather.Fog.rawValue)
        case "Cloudy":
            mainView.iconLabel.text = String(format: "%C", Weather.Cloudy.rawValue)
        case "PartlyCloudyDay":
            mainView.iconLabel.text = String(format: "%C", Weather.PartlyCloudyDay.rawValue)
        case "PartlyCloudyNight":
            mainView.iconLabel.text = String(format: "%C", Weather.PartlyCloudyNight.rawValue)
        default:
            mainView.iconLabel.text = String(format: "%C", Weather.Cloudy.rawValue)
        }
        mainView.humidityIconLabel.text = String(format: "%C", Weather.Humidity.rawValue)
        let humidityCalc = currentWeather.humidity * 100
        mainView.humidityLabel.text = "\(humidityCalc)%"
        mainView.precProbIconLabel.text = String(format: "%C", Weather.Rainy.rawValue)
        let precProbCalc = currentWeather.precipProbability * 100
        mainView.precProbLabel.text = "\(precProbCalc)%"
        mainView.summaryLabel.text = currentWeather.summary
        mainView.dateLabel.text = dateTime.displayDate()
//        mainView.arrowRight.titleLabel.text = String(format: "%C", Arrow.Right.rawValue)
        mainView.sunriseTimeIconLabel.text = String(format: "%C", Weather.Sunrise.rawValue)
        mainView.sunsetTimeIconLabel.text = String(format: "%C", Weather.Sunset.rawValue)
        mainView.windSpeedIconLabel.text = String(format: "%C", Weather.Windy.rawValue)
        mainView.precipIntensityIconLabel.text = String(format: "%C", Weather.Intensity.rawValue)
        mainView.sunriseTimeLabel.text = currentWeather.sunriseTime
        mainView.sunsetTimeLabel.text = currentWeather.sunsetTime
        mainView.windSpeedLabel.text = "\(currentWeather.windSpeed)"
        mainView.precipIntensityLabel.text = "\(currentWeather.precipIntensity)"
        
    }
    //MARK: Fetching Data
    func fetchDataFromCore() {
        newTodayWeatherStored = WeatherDataToday.fetchDataInManagedObjectContext(managedObjectContext!)
        let jsonResult = NSJSONSerialization.JSONObjectWithData(newTodayWeatherStored.jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        currentWeather = Current(weatherDictionary: jsonResult)
        currentWeather.currentCoordenates = newTodayWeatherStored.coordString
        if CLLocationManager.locationServicesEnabled() {
            self.getGeoLocation(self.locationManager)
        }
        currentWeather.lastUpdate = newTodayWeatherStored.dateStored
        
        if dateTime.shouldGetDataFromAPI(currentWeather.lastUpdate!) {
            getDataFromAPI(currentWeather.currentCoordenates!)
        } else if dateTime.calculateDelayTime(currentWeather.lastUpdate!) > 0 {
            getDataForDelay(dateTime.calculateDelayTime(currentWeather.lastUpdate!))
        }
        loadData()
    }
    
    func getDataFromAPI(coorString: String) {

        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let lang = NSLocale.currentLocale()
        var langAndUnits: String
        switch lang.localeIdentifier {
            case "es_ES":
                langAndUnits = "?lang=es&units=auto"
        default:
            langAndUnits = "?units=auto"
        }
        let forecastURL = NSURL(string: "\(coorString)\(langAndUnits)", relativeToURL: baseURL!)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var dataObject = NSData(contentsOfURL: location)
                    var error: NSError?
                    let weatherDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: &error) as! NSDictionary
                    if error == nil {
                        self.currentWeather = Current(weatherDictionary: weatherDictionary)
                        self.currentWeather.currentCoordenates = coorString
                        if CLLocationManager.locationServicesEnabled() {
                            self.getGeoLocation(self.locationManager)
                        }
                        if WeatherDataToday.isEmpty(self.managedObjectContext!) {
                            WeatherDataToday.saveInManagedObjectContext(self.managedObjectContext!, lastUpdate: self.dateTime.getDateForLastUpdate(), data: dataObject!, coordString: coorString)
                        } else {
                            WeatherDataToday.updateInManagedObjectContext(self.managedObjectContext!, lastUpdate: self.dateTime.getDateForLastUpdate(), data: dataObject!, coordString: coorString)
                        }
                        self.currentWeather.lastUpdate = self.dateTime.getDateForLastUpdate()
                        self.loadData()
                    } else {
                        println(error)
                    }
                })
            }

        })
        downloadTask.resume()
    }
    
    //MARK: Location
    
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        let authState = CLLocationManager.authorizationStatus()
        if authState == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
            if WeatherDataToday.isEmpty(managedObjectContext!) {
                //Set coordenates to a certain location//default coordinates
                let coorString = "37.331705,-122.030237"
                //get data with default coordinates from API
                getDataFromAPI(coorString)
            }
            let alertLocation = UIAlertController(title: "Oh Oh!", message: NSLocalizedString("Without access to your location this information may be wrong", comment: "alertLocation message"), preferredStyle: .Alert)
            let dissmissAction = UIAlertAction(title: NSLocalizedString("Dissmiss", comment: "dismissButton text"), style: .Cancel, handler: { (action) -> Void in
                return
            })
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "settingsButton text"), style: .Default, handler: { (action) -> Void in
                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(settingsURL!)
            })
            alertLocation.addAction(dissmissAction)
            alertLocation.addAction(settingsAction)
            self.presentViewController(alertLocation, animated: true, completion: { () -> Void in
                return
            })
        }
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation: AnyObject = locations.last!
        let locationAge: NSDate = newLocation.timestamp!
        let coorString = "\(locations.last!.coordinate.latitude),\(locations.last!.coordinate.longitude)"
        
        if locationAge.timeIntervalSinceNow > 10.0 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        if currentWeather == nil && newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            getDataFromAPI(coorString)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func getGeoLocation(manager: CLLocationManager!) {
        //default coordinates
        let geoCoder = CLGeocoder()
        var placemark: AnyObject
        var error: NSError
        geoCoder.reverseGeocodeLocation(manager.location, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                println("Error: \(error.localizedDescription)")
                return
            }
            if placemark.count > 0 {
                let pm = placemark[0] as! CLPlacemark
                self.currentWeather.currentLocation = "\(pm.locality), \(pm.country)"
                self.mainView.locationLabel.text = self.currentWeather.currentLocation
            } else {
                println("Error with data")
            }
        })
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func getDataForDelay(arg: Int) {
        var delay: NSTimeInterval
        var dateForDelay: NSDate
        delay = Double(arg) * 3600.0
        
        dateForDelay = currentWeather.lastUpdate!.dateByAddingTimeInterval(delay)
        if let givenHourWeather = currentWeather.getDataFromGivenHour(round(dateForDelay.timeIntervalSince1970)) as? NSDictionary {
            var newTemp = round(givenHourWeather["temperature"]as! Double)
            currentWeather.temperature = Int(newTemp)
            currentWeather.icon = currentWeather.weatherIconFromString(String(givenHourWeather["icon"]! as! NSString))
            currentWeather.humidity = givenHourWeather["humidity"] as! Double
            currentWeather.precipProbability = givenHourWeather["precipProbability"] as! Double
            currentWeather.summary = givenHourWeather["summary"] as! String
            currentWeather.windSpeed = givenHourWeather["windSpeed"] as! Double
            currentWeather.precipIntensity = (givenHourWeather["precipIntensity"] as! Double).format(".2")
            loadData()
        } else {
            getDataFromAPI(currentWeather.currentCoordenates!)
        }
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        attributedString = NSAttributedString(string: pickerData[row], attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 26.0)!,NSForegroundColorAttributeName:UIColor.lightTextColor()])
        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            getDataForDelay(row)
        } else {
            fetchDataFromCore()
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 26.0)!,NSForegroundColorAttributeName:UIColor.lightTextColor()])
        pickerLabel!.textAlignment = .Center
        pickerLabel!.attributedText = myTitle
        
        return pickerLabel
    }
    
}



