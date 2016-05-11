//
//  WeatherData.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/10/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation

/**
 A class that holds a zip code and weather data that relates to that zip code.
 */
class WeatherData{
    
    var zipCode:Int
    var latitude:Double?
    var longitude:Double?
    var placeName:String?
    /**
    Returns the current temperature with units according to the setting in SharedData.
    Set the current temperature with degrees Kelvin.
    */
    var currentTemperature:Double?{
        get{
            guard let kelvinTemp = currentTemperatureKelvin else{return nil}
            if(SharedData.sharedInstance.fahrenheit){return toFahrenheit(kelvinTemp)}
            return toCelsius(kelvinTemp)
        }
        set(newValue){
            currentTemperatureKelvin = newValue
        }
    }
    var currentTemperatureKelvin:Double?
    
    init(zipCode: Int){
        self.zipCode = zipCode
    }
    
    
}
func toFahrenheit(degreesKelvin: Double)->Double{
    //return degreesKelvin * 9/5 - 459.67
    return 9/5 * (degreesKelvin - 273.15) + 32
}

func toCelsius(degreesKelvin:Double)->Double{
    return degreesKelvin - 273.15
}
/**
 Singleton to hold weather data.
 */
class SharedData {
    
    // MARK: Public Variables
    static let sharedInstance = SharedData()
    
    var data = [WeatherData]()
    
    var fahrenheit: Bool = true
    
    var degreeLabel: String{
        get{
            if(fahrenheit){return Constants.degreesFahrenheit}
            return Constants.degreesCelsius
        }
    }
}

struct DailyForecast{
    var date:String
    var minTemp:Double {
        get{
        if(SharedData.sharedInstance.fahrenheit){return toFahrenheit(minTempKelvin)}
        return toCelsius(minTempKelvin)
    }
        set(newValue){
        minTempKelvin = newValue
        }
    }
    var maxTemp:Double {
        get{
            if(SharedData.sharedInstance.fahrenheit){return toFahrenheit(maxTempKelvin)}
            return toCelsius(maxTempKelvin)
        }
        set(newValue){
            maxTempKelvin = newValue
        }
    }
    var minTempKelvin:Double
    var maxTempKelvin:Double
    
    init(date:String, minTempKelvin:Double, maxTempKelvin: Double){
        self.date = date
        self.minTempKelvin = minTempKelvin
        self.maxTempKelvin = maxTempKelvin
    }
}