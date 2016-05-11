//
//  FirstViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationGetterDelegate, OpenWeatherClientDelegate {
    
    // MARK: Properties
    let sharedData = SharedData.sharedInstance
    let storedData = NSUserDefaults.standardUserDefaults()
    
    let locationGetter = LocationGetter()
    let openWeatherClient = OpenWeatherClient()
    let zipCodeDelegate = ZipCodeTextFieldDelegate()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var degreeChangeButton: UIButton!
    
    
    @IBAction func degreeChangeButtonPressed(sender: UIButton) {
        if(SharedData.sharedInstance.fahrenheit){
            sharedData.fahrenheit = false
            sender.setTitle(Constants.degreesFahrenheit, forState: .Normal)
        }else{
            sharedData.fahrenheit = true
            sender.setTitle(Constants.degreesCelsius, forState: .Normal)
        }
        tableView.reloadData()
        storedData.setBool(sharedData.fahrenheit, forKey: "displayFahrenheit")
    }
    
    // MARK: Loading and disappearing methods
    override func viewWillDisappear(animated: Bool) {
        print("view will disappear")
        var zipCodeArray = [Int]()
        for datum in sharedData.data{
            zipCodeArray.append(datum.zipCode)
        }
        storedData.setObject(zipCodeArray, forKey: "storedZipCode")
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        openWeatherClient.delegate = self
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
        
        self.zipCodeTextField.delegate = self.zipCodeDelegate
        
        print(sharedData.data.count)
        self.navigationController?.navigationBarHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneAndCurrentLocationButtonsOnKeyboard()
        
        
        // set defaults
        let pathForDefaults = NSBundle.mainBundle().pathForResource("Default Settings", ofType: "plist")
        let defaultDictionary = NSDictionary(contentsOfFile: pathForDefaults!)
        print(defaultDictionary)
        
        storedData.registerDefaults(defaultDictionary as! [String : AnyObject])
        print(storedData.boolForKey("displayFahrenheit"))
        setDefaultTemperatureUnit(storedData.boolForKey("displayFahrenheit"))
        
        if let zipCodeArray = storedData.arrayForKey("storedZipCode") as? [Int]{
            print("converted")
            print(zipCodeArray)
            for code in zipCodeArray{
                let weatherData = WeatherData(zipCode: code)
                sharedData.data.append(weatherData)
                openWeatherClient.updateCurrentTemperature(weatherData)
            }
        }
        
    }
    
    private func setDefaultTemperatureUnit(fahrenheit: Bool){
        sharedData.fahrenheit = fahrenheit
        if(fahrenheit){degreeChangeButton.setTitle(Constants.degreesCelsius, forState: .Normal)}
        else{degreeChangeButton.setTitle(Constants.degreesFahrenheit, forState: .Normal)}
    }
    
    // taken from http://iostechsolutions.blogspot.com/2014/11/swift-add-uitoolbar-or-done-button-on.html because the number pad doesn't have a return key... (and a touch gesture outside the keypad might conflict with selecting a cell)
    func addDoneAndCurrentLocationButtonsOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 50))
        doneToolbar.barStyle = .Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(TableViewController.doneButtonAction))
        
        let currentLocationButton: UIBarButtonItem = UIBarButtonItem(title: "Use Current Location", style: .Done, target: self, action: #selector(TableViewController.startGettingCurrentLocation))
        
        var items = [UIBarButtonItem]()
        items.append(currentLocationButton)
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        
        doneToolbar.sizeToFit()
        
        self.zipCodeTextField.inputAccessoryView = doneToolbar
        self.zipCodeTextField.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction() {
        self.zipCodeTextField.resignFirstResponder()
        if(zipCodeTextField.text?.characters.count == 5){
            let newZip = Int(zipCodeTextField.text!)!
            
            let newWeatherData = WeatherData(zipCode: newZip)
            sharedData.data.append(newWeatherData)
            self.tableView.reloadData()
            openWeatherClient.updateCurrentTemperature(newWeatherData)
        }
    }
    
    
    // MARK: Current Location Methods
    func startGettingCurrentLocation(){
        self.zipCodeTextField.resignFirstResponder()
        self.zipCodeTextField.text = "Retrieving current location..."
        
        locationGetter.foundZipCode = false
        locationGetter.delegate = self
        locationGetter.startGettingZipCode()
    }
    func receiveCurrentZipCode(zipCode: Int) {
        self.zipCodeTextField.text = ""
        
        let weatherData = WeatherData(zipCode: zipCode)
        sharedData.data.append(weatherData)
        openWeatherClient.updateCurrentTemperature(weatherData)
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    func couldNotGetCurrentZipCode(){
        zipCodeTextField.text = "Couldn't retrieve location"
    }
    func alreadyFoundCurrentZipCode(){
        zipCodeTextField.text = "Already found the current location"
    }
    
    // MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // show 5 day view
        openWeatherClient.getForecastForWeatherData(sharedData.data[indexPath.row])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedData.data.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell") as! TemperatureCell
        let zip = self.sharedData.data[indexPath.row].zipCode
        
        cell.zipCodeLabel.text = String(zip)
        
        if let temperature = sharedData.data[indexPath.row].currentTemperature{
            cell.temperatureLabel.text = String(format: "%.1f", temperature) + SharedData.sharedInstance.degreeLabel
        }else{cell.temperatureLabel.text = "No connection"}
        
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            sharedData.data.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    
    //MARK: OpenWeatherClient Delegate Methods
    func receivedUpdatedCurrentTemperature(){
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    func receivedForecast(fiveDayArray: [DailyForecast], currentTemperature:String){
        dispatch_async(dispatch_get_main_queue()){
            self.instantiateDetailView(fiveDayArray, currentTemperature: currentTemperature)
        }
    }
    func failedToUpdate(error:String){
        zipCodeTextField.text = error
        print(error)
    }
    func instantiateDetailView(fiveDayArray: [DailyForecast], currentTemperature:String){
        let controller = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        controller.fiveDayArray = fiveDayArray
        controller.currentTemperature = currentTemperature
        
        navigationController!.pushViewController(controller, animated: true)
    }
}

