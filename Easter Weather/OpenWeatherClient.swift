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

// MARK: Methods
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
