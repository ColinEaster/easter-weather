//
//  DetailViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/11/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var fiveDayArray:[DailyForecast]!
    var currentTemperature:String!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        takeAPhoto()
    }
    override func viewWillAppear(animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
        self.navigationController?.navigationBarHidden = false
        self.title = "Five Day Forecast"
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
    
    private func takeAPhoto() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
        controller.currentTemperature = self.currentTemperature
        navigationController!.pushViewController(controller, animated: true)
    }
    
}