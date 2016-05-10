//
//  FirstViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var zipcode = [Int]()
    let zipCodeDelegate = ZipCodeTextFieldDelegate()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    
    
    override func viewWillAppear(animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
        
        self.zipCodeTextField.delegate = self.zipCodeDelegate
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.addDoneButtonOnKeyboard()
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
        
        cell.zipCodeLabel.text = String(zip)
        cell.temperatureLabel.text = String(75)
        
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            zipcode.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    // taken from http://iostechsolutions.blogspot.com/2014/11/swift-add-uitoolbar-or-done-button-on.html because the number pad doesn't have a return key... (and a touch gesture outside the keypad might conflict with selecting a cell)
    func addDoneButtonOnKeyboard()
    {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 50))
        doneToolbar.barStyle = .Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(TableViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        
        doneToolbar.sizeToFit()
        
        self.zipCodeTextField.inputAccessoryView = doneToolbar
        self.zipCodeTextField.inputAccessoryView = doneToolbar
        
    }
    func doneButtonAction()
    {
        self.zipCodeTextField.resignFirstResponder()
        if(zipCodeTextField.text?.characters.count == 5){
            let newZip = Int(zipCodeTextField.text!)!
            zipcode.append(newZip)
            self.tableView.reloadData()
            updateCurrentTemperature(newZip)
        }
    }
    
    // MARK: API Request
    private func updateCurrentTemperature(withZipCode: Int) {
        
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: getCurrentWeatherURL(withZipCode))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                print("error")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            
            /* GUARD: Is the "photos" key in our result? */
            guard let weatherDictionary = parsedResult["main"] as? [String:AnyObject] else {
                print(parsedResult)
                return
            }
            
            print(parsedResult)
            
            
        }
        
        // start the task
        task.resume()
    }
    func getCurrentWeatherURL(zipCode: Int)->NSURL{
        let url:String = Constants.ApiString + Methods.ZIP + String(zipCode) + ",us" + Constants.ApiKey
        return NSURL(string: url)!
    }
}

