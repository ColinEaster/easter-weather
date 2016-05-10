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
            zipcode.append(Int(zipCodeTextField.text!)!)
            self.tableView.reloadData()
        }
    }
    
}

