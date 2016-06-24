//
//  TemperatureCell.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class TemperatureCell: UITableViewCell {
    
    @IBOutlet weak var zipCodeLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    func configureWithWeatherData(withData: WeatherData){
        
        let zip = withData.zipCode
        
        zipCodeLabel.text = String(zip)
        
        if let temperature = withData.currentTemperature{
            temperatureLabel.text = String(format: "%.1f", temperature) + SharedData.sharedInstance.degreeLabel
        }else{temperatureLabel.text = "No connection"}
    }
    
}
