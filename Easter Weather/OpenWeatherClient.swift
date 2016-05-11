//
//  OpenWeatherClient.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/10/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation

// MARK: Constants
struct Constants {
    
    // MARK: API Key
    static let ApiKey : String = "&appid=3b535043693316ba125a0513276aa62d"
    
    // MARK: URLs
    static let ApiScheme = "http"
    static let ApiHost = "api.openweathermap.org"
    static let ApiPath = "/data/2.5"
    static let ApiString = "http://api.openweathermap.org/data/2.5"
    
    static let degreesFahrenheit = "°F"
    static let degreesCelsius = "°C"
}

// MARK: Methods and Parameters
struct Methods {
    
    // MARK: Weather by zip code
    static let ZIP = "/weather?zip="
    static let CountryCode = ",us"
    
    // MARK: 5 day forecast
    static let Forecast = "/forecast/daily?"
    static let Latitude = "lat="
    static let Longitude = "&lon="
    static let Count = "&cnt="
}

/**
 MARK: OpenWeatherClient
 */
class OpenWeatherClient{
    
    // MARK: Property
    var delegate: OpenWeatherClientDelegate?
    
    // MARK: Network Request Methods
    func updateCurrentTemperature(withData: WeatherData) {
        
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: getCurrentWeatherURL(withData.zipCode))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.delegate?.failedToUpdate("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.delegate?.failedToUpdate("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.delegate?.failedToUpdate("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                self.delegate?.failedToUpdate("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            
            guard let weatherDictionary = parsedResult["main"] as? [String:Double] else {
                self.delegate?.failedToUpdate("Could not parse 'main'")
                print(parsedResult)
                return
            }
            
            if let coordDictionary = parsedResult["coord"] as? [String:Double]{
                print("received coords")
                withData.latitude = coordDictionary["lat"]
                withData.longitude = coordDictionary["lon"]
                
            }
            
            if let temperature = weatherDictionary["temp"]{
                print(temperature)
                withData.currentTemperature = temperature
                self.delegate?.receivedUpdatedCurrentTemperature()
            }
            
        }
        
        // start the task
        task.resume()
    }
    
    func getForecastForWeatherData(weatherData:WeatherData){
        print("getting forecast")
        guard let url = getForecastURL(weatherData) else{
            self.delegate?.failedToUpdate("Can't connect for detailed data.")
            return
        }
        print(url)
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url)
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.delegate?.failedToUpdate("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.delegate?.failedToUpdate("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.delegate?.failedToUpdate("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                self.delegate?.failedToUpdate("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            var fiveDayArray = [DailyForecast]()
            guard let list = parsedResult.objectForKey("list") as? [AnyObject] else{
                self.delegate?.failedToUpdate("couldn't parse list")
                return
            }
            
            for i in list {
                let time = i["dt"] as! Double
                let date = self.dayStringFromTime(time)
                
                let minTemp = i["temp"]!!["min"] as! Double
                let maxTemp = i["temp"]!!["max"] as! Double
                
                let forecast = DailyForecast(date: date, minTempKelvin: minTemp, maxTempKelvin: maxTemp)
                fiveDayArray.append(forecast)
            }
            print(fiveDayArray)
            let currentTemp = String(format: "%.0f", weatherData.currentTemperature!) + SharedData.sharedInstance.degreeLabel
            self.delegate?.receivedForecast(fiveDayArray, currentTemperature: currentTemp)
            
        }
        task.resume()
    }
    
    func getCurrentWeatherURL(zipCode: Int)->NSURL{
        let url:String = Constants.ApiString + Methods.ZIP + String(zipCode) + ",us" + Constants.ApiKey
        return NSURL(string: url)!
    }
    func getForecastURL(weatherData: WeatherData)->NSURL?{
        guard let lat = weatherData.latitude, long = weatherData.longitude else{
            print("no long/lat")
            return nil
        }
        
        let url:String = Constants.ApiString + Methods.Forecast + "lat=\(lat)&lon=\(long)" + Methods.Count + "5" + Constants.ApiKey
        return NSURL(string: url)
    }
    
    func dayStringFromTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = NSTimeZone.localTimeZone() // should put it in the correct time zone
        return dateFormatter.stringFromDate(date)
    }
}

// MARK: Protocol
protocol OpenWeatherClientDelegate {
    func receivedUpdatedCurrentTemperature()
    func receivedForecast(fiveDayForecast: [DailyForecast], currentTemperature: String)
    func failedToUpdate(error:String)
}
