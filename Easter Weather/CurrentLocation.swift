//
//  CurrentLocation.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/10/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import Foundation
import CoreLocation

class LocationGetter: NSObject, CLLocationManagerDelegate{
    
    // MARK: Properties
    let locationManager = CLLocationManager()
    var delegate: LocationGetterDelegate?
    var foundZipCode = false
    
    // MARK: Init
    override init(){
        print("init location getter")
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        
    }
    /**
    Starts the process of getting the current location.
    */
    func startGettingZipCode(){
        if(foundZipCode){delegate?.alreadyFoundCurrentZipCode();return}
        locationManager.startUpdatingLocation()
    }
    // MARK: Location Manager Delegate Methods
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("Error while updating location " + error.localizedDescription)
        self.delegate?.couldNotGetCurrentZipCode()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(locations[0], completionHandler: {(placemarks, error) -> Void in
    
            if let err = error{
                print("Reverse geocoder failed with error" + err.localizedDescription)
                self.delegate?.couldNotGetCurrentZipCode()
                return
            }
            
            if let places = placemarks{
                if(places.count > 0 && self.foundZipCode != true){self.delegate?.receiveCurrentZipCode(self.retreiveZipCodeFromPlacemark(places[0]))}
            }
            
        })
    }
    
    private func retreiveZipCodeFromPlacemark(placemark: CLPlacemark)->Int {
        
        print("Current zip code: \(placemark.postalCode)")
        
        if let code = placemark.postalCode{
            if let num = Int(code){
                foundZipCode = true
                return num
            }
        }
        self.delegate?.couldNotGetCurrentZipCode()
        return 0
    }
}
// MARK: LocationGetterDelegate
protocol LocationGetterDelegate {
    func receiveCurrentZipCode(zipCode: Int)
    func couldNotGetCurrentZipCode()
    func alreadyFoundCurrentZipCode()
}