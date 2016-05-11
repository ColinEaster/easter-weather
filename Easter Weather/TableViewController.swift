//
//  FirstViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationGetterDelegate {
    
    let sharedData = SharedData.sharedInstance
    let storedData = NSUserDefaults.standardUserDefaults()
    let locationGetter = LocationGetter()
    
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
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
        
        self.zipCodeTextField.delegate = self.zipCodeDelegate
        
        //sharedData.data = SharedData.sharedInstance.data
        print(sharedData.data.count)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneAndCurrentLocationButtonsOnKeyboard()
        
        // RESET PERSISTENT DATA
        //let appDomain = NSBundle.mainBundle().bundleIdentifier!
        //NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        
        
        
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
                updateCurrentTemperature(weatherData)
            }
        }
        
    }
    private func setDefaultTemperatureUnit(fahrenheit: Bool){
        sharedData.fahrenheit = fahrenheit
        if(fahrenheit){degreeChangeButton.setTitle(Constants.degreesCelsius, forState: .Normal)}
        else{degreeChangeButton.setTitle(Constants.degreesFahrenheit, forState: .Normal)}
    }
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
        updateCurrentTemperature(weatherData)
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.tableView.reloadData()
        }
    }
    func couldNotGetCurrentZipCode(){
        zipCodeTextField.text = "Couldn't retreive the current location."
    }
    func alreadyFoundCurrentZipCode(){
        zipCodeTextField.text = "Already found the current location."
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // show 5 day view
        getForecastForWeatherData(sharedData.data[indexPath.row])
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
        }else{cell.temperatureLabel.text = ""}
        //cell.temperatureLabel.text = String(data[indexPath.row].currentTemperature)
        
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
    
    // taken from http://iostechsolutions.blogspot.com/2014/11/swift-add-uitoolbar-or-done-button-on.html because the number pad doesn't have a return key... (and a touch gesture outside the keypad might conflict with selecting a cell)
    func addDoneAndCurrentLocationButtonsOnKeyboard()
    {
        
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
    func doneButtonAction()
    {
        self.zipCodeTextField.resignFirstResponder()
        if(zipCodeTextField.text?.characters.count == 5){
            let newZip = Int(zipCodeTextField.text!)!
            
            let newWeatherData = WeatherData(zipCode: newZip)
            sharedData.data.append(newWeatherData)
            self.tableView.reloadData()
            updateCurrentTemperature(newWeatherData)
        }
    }
    
    // MARK: API Request
    private func updateCurrentTemperature(withData: WeatherData) {
        
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: getCurrentWeatherURL(withData.zipCode))
        
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
            
            
            
            guard let weatherDictionary = parsedResult["main"] as? [String:Double] else {
                print(parsedResult)
                return
            }
            
            if let coordDictionary = parsedResult["coord"] as? [String:Double]{
                print("received coords")
                withData.latitude = coordDictionary["lat"]
                withData.longitude = coordDictionary["lon"]
                print(withData.latitude)
                print(withData.longitude)
            }
            
            if let temperature = weatherDictionary["temp"]{
                print("yes")
                print(temperature)
                withData.currentTemperature = temperature
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.tableView.reloadData()
                }
            }
            
        }
        
        // start the task
        task.resume()
    }
    
    private func getForecastForWeatherData(weatherData:WeatherData){
        print("getting forecast")
        guard let url = getForecastURL(weatherData) else{
            zipCodeTextField.text = "Can't get detailed data."
            return
        }
        print(url)
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url)
        
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
            
            
            var fiveDayArray = [DailyForecast]()
            guard let list = parsedResult.objectForKey("list") as? [AnyObject] else{
                print("couldn't parse list")
                return
            }
            
            for i in list {
                let time = i["dt"] as! Double
                let date = self.dayStringFromTime(time)
                
                let minTemp = i["temp"]!!["min"] as! Double
                let maxTemp = i["temp"]!!["max"] as! Double
                
                let forecast = DailyForecast(date: date, minTempKelvin: minTemp, maxTempKelvin: maxTemp)
                fiveDayArray.append(forecast)
            }
            print(fiveDayArray)
            dispatch_async(dispatch_get_main_queue()){
                self.instantiateDetailView(fiveDayArray)
            }
        }
        task.resume()
    }
    func instantiateDetailView(fiveDayArray: [DailyForecast]){
        let controller = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        controller.fiveDayArray = fiveDayArray
        //navigationController!.pushViewController(controller, animated: true)
        presentViewController(controller, animated: true, completion: nil)
    }
    func getCurrentWeatherURL(zipCode: Int)->NSURL{
        let url:String = Constants.ApiString + Methods.ZIP + String(zipCode) + ",us" + Constants.ApiKey
        return NSURL(string: url)!
    }
    func getForecastURL(weatherData: WeatherData)->NSURL?{
        guard let lat = weatherData.latitude, long = weatherData.longitude else{
            print("no long/lat")
            return nil
        }
    
        let url:String = Constants.ApiString + Methods.Forecast + "lat=\(lat)&lon=\(long)" + Methods.Count + "5" + Constants.ApiKey
        return NSURL(string: url)
    }
    
    func dayStringFromTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        //dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        //dateFormatter.timeZone = NSTimeZone()
        return dateFormatter.stringFromDate(date)
    }
}

