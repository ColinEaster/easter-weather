//
//  FirstViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var zipcode = [17042, 18042]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // show 5 day view
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipcode.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell") as! TemperatureCell
        let zip = self.zipcode[indexPath.row]
        
        // Set the name and image
        cell.zipCodeLabel.text = String(zip)
        cell.temperatureLabel.text = String(75)
        
        return cell
    }

}

