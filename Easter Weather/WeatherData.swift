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
    var currentTemperature:Double?
    
    init(zipCode: Int){
        self.zipCode = zipCode
    }
}

/**
 Singleton to hold weather data.
 */
class SharedData {
    
    // MARK: Public Variables
    static let sharedInstance = SharedData()
    
    var data = [WeatherData]()
    
    var fahrenheit: Bool = true
}
