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
    fileprivate let apiKey = "1230094637b31f01c8bfaddb0587a4bc"
    
    var mainView: MainView!
    let colorWheel = ColorWheel()
    var pickerData = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    var currentWeather: Current!
    var newTodayWeatherStored: WeatherDataToday!
    var dateTime: DateTime!
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    let locationManager: CLLocationManager = CLLocationManager()
    
    //MARK: -Override funcs
    override func loadView() {
        let applicationFrame: CGRect = UIScreen.main.bounds
        let contentView: UIView = UIView(frame: applicationFrame)
        contentView.backgroundColor = colorWheel.randomColor()
        
        view = contentView
        
        let principalView = UIView()
        let otherView = UIView()
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
        let hours = ((0 + 1)...dateTime.getHour()).reversed()
        for i in hours {
            pickerData.remove(at: i-1)
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
            mainView.iconLabel.text = String(format: "%C", Weather.clearDay.rawValue)
        case "ClearNight":
            mainView.iconLabel.text = String(format: "%C", Weather.clearNight.rawValue)
        case "Rainy":
            mainView.iconLabel.text = String(format: "%C", Weather.rainy.rawValue)
        case "Snowy":
            mainView.iconLabel.text = String(format: "%C", Weather.snowy.rawValue)
        case "Sleet":
            mainView.iconLabel.text = String(format: "%C", Weather.sleet.rawValue)
        case "Windy":
            mainView.iconLabel.text = String(format: "%C", Weather.windy.rawValue)
        case "Fog":
            mainView.iconLabel.text = String(format: "%C", Weather.fog.rawValue)
        case "Cloudy":
            mainView.iconLabel.text = String(format: "%C", Weather.cloudy.rawValue)
        case "PartlyCloudyDay":
            mainView.iconLabel.text = String(format: "%C", Weather.partlyCloudyDay.rawValue)
        case "PartlyCloudyNight":
            mainView.iconLabel.text = String(format: "%C", Weather.partlyCloudyNight.rawValue)
        default:
            mainView.iconLabel.text = String(format: "%C", Weather.cloudy.rawValue)
        }
        mainView.humidityIconLabel.text = String(format: "%C", Weather.humidity.rawValue)
        let humidityCalc = currentWeather.humidity * 100
        mainView.humidityLabel.text = "\(humidityCalc)%"
        mainView.precProbIconLabel.text = String(format: "%C", Weather.rainy.rawValue)
        let precProbCalc = currentWeather.precipProbability * 100
        mainView.precProbLabel.text = "\(precProbCalc)%"
        mainView.summaryLabel.text = currentWeather.summary
        mainView.dateLabel.text = dateTime.displayDate()
//        mainView.arrowRight.titleLabel.text = String(format: "%C", Arrow.Right.rawValue)
        mainView.sunriseTimeIconLabel.text = String(format: "%C", Weather.sunrise.rawValue)
        mainView.sunsetTimeIconLabel.text = String(format: "%C", Weather.sunset.rawValue)
        mainView.windSpeedIconLabel.text = String(format: "%C", Weather.windy.rawValue)
        mainView.precipIntensityIconLabel.text = String(format: "%C", Weather.intensity.rawValue)
        mainView.sunriseTimeLabel.text = currentWeather.sunriseTime
        mainView.sunsetTimeLabel.text = currentWeather.sunsetTime
        mainView.windSpeedLabel.text = "\(currentWeather.windSpeed)"
        mainView.precipIntensityLabel.text = "\(currentWeather.precipIntensity)"
        
    }
    //MARK: Fetching Data
    func fetchDataFromCore() {
        newTodayWeatherStored = WeatherDataToday.fetchDataInManagedObjectContext(managedObjectContext!)
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: newTodayWeatherStored.jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
            currentWeather = Current(weatherDictionary: jsonResult as! NSDictionary)
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
        } catch {
            let nserror = error as NSError
            print(nserror.localizedDescription)
        }
    }
    
    func getDataFromAPI(_ coorString: String) {

        let baseURL = URL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let lang = Locale.current
        var langAndUnits: String
        switch lang.identifier {
            case "es_ES":
                langAndUnits = "?lang=es&units=auto"
        default:
            langAndUnits = "?units=auto"
        }
        let forecastURL = URL(string: "\(coorString)\(langAndUnits)", relativeTo: baseURL!)
        
        let sharedSession = URLSession.shared
        let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(with: forecastURL!) { (location, response, error) in
            if error == nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    if let dataObject = NSData.init(contentsOf: location!) {
                        if let weatherDictionary = try? JSONSerialization.jsonObject(with: dataObject as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary {
                            self.currentWeather = Current(weatherDictionary: weatherDictionary)
                            self.currentWeather.currentCoordenates = coorString
                            if CLLocationManager.locationServicesEnabled() {
                                self.getGeoLocation(self.locationManager)
                            }
                            if WeatherDataToday.isEmpty(self.managedObjectContext!) {
                                WeatherDataToday.saveInManagedObjectContext(self.managedObjectContext!, lastUpdate: self.dateTime.getDateForLastUpdate(), data: dataObject as Data, coordString: coorString)
                            } else {
                                WeatherDataToday.updateInManagedObjectContext(self.managedObjectContext!, lastUpdate: self.dateTime.getDateForLastUpdate(), data: dataObject as Data, coordString: coorString)
                            }
                            self.currentWeather.lastUpdate = self.dateTime.getDateForLastUpdate()
                            self.loadData()
                        }
                    }
                    } as @convention(block) () -> Void)
            }

        }
        downloadTask.resume()
    }
    
    //MARK: Location
    
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        let authState = CLLocationManager.authorizationStatus()
        if authState == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            if WeatherDataToday.isEmpty(managedObjectContext!) {
                //Set coordenates to a certain location//default coordinates
                let coorString = "37.331705,-122.030237"
                //get data with default coordinates from API
                getDataFromAPI(coorString)
            }
            let alertLocation = UIAlertController(title: "Oh Oh!", message: NSLocalizedString("Without access to your location this information may be wrong", comment: "alertLocation message"), preferredStyle: .alert)
            let dissmissAction = UIAlertAction(title: NSLocalizedString("Dissmiss", comment: "dismissButton text"), style: .cancel, handler: { (action) -> Void in
                return
            })
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "settingsButton text"), style: .default, handler: { (action) -> Void in
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(settingsURL!)
            })
            alertLocation.addAction(dissmissAction)
            alertLocation.addAction(settingsAction)
            self.present(alertLocation, animated: true, completion: { () -> Void in
                return
            })
        }
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation: AnyObject = locations.last!
        let locationAge: Date = newLocation.timestamp!
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getGeoLocation(_ manager: CLLocationManager!) {
        //default coordinates
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(manager.location!, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                print("Error: \(String(describing: error?.localizedDescription))")
                return
            }
            if (placemark?.count)! > 0 {
                if let pm = placemark?[0] {
                    self.currentWeather.currentLocation = "\(pm.locality!), \(pm.country!)"
                    self.mainView.locationLabel.text = self.currentWeather.currentLocation
                }
            } else {
                print("Error with data")
            }
        })
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func getDataForDelay(_ arg: Int) {
        var delay: TimeInterval
        var dateForDelay: Date
        delay = Double(arg) * 3600.0
        
        dateForDelay = currentWeather.lastUpdate!.addingTimeInterval(delay) as Date
        if let givenHourWeather = currentWeather.getDataFromGivenHour(round(dateForDelay.timeIntervalSince1970)) as? NSDictionary {
            let newTemp = round(givenHourWeather["temperature"]as! Double)
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
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        attributedString = NSAttributedString(string: pickerData[row], attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 26.0)!,NSForegroundColorAttributeName:UIColor.lightText])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            getDataForDelay(row)
        } else {
            fetchDataFromCore()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 26.0)!,NSForegroundColorAttributeName:UIColor.lightText])
        pickerLabel!.textAlignment = .center
        pickerLabel!.attributedText = myTitle
        
        return pickerLabel!
    }
    
}



