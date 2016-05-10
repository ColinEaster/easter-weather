//
//  WeatherData.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/10/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation

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