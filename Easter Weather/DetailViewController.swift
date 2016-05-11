//
//  DetailViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/11/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var fiveDayArray:[DailyForecast]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiveDayArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailViewCell") as! DetailViewCell
        
        let forecast = fiveDayArray[indexPath.row]
        cell.dateLabel.text = forecast.date
        cell.lowTempLabel.text = "Low: " + String(format: "%.0f", forecast.minTemp) + SharedData.sharedInstance.degreeLabel
        cell.highTempLabel.text = "High: " + String(format: "%.0f", forecast.maxTemp) + SharedData.sharedInstance.degreeLabel
        
        return cell
    }
    
}