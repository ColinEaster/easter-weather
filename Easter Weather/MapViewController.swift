//
//  SecondViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    let sharedData = SharedData.sharedInstance
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Place Pins
    override func viewWillAppear(animated: Bool) {
        sharedData.data = SharedData.sharedInstance.data
        
        mapView.delegate = self
        
        var annotations = [MKPointAnnotation]()
        print(sharedData.data.count)
        for datum in sharedData.data {
            
            // skip this entry if it doesn't have a lat/long
            guard let lat = datum.latitude, long = datum.longitude else{
                continue
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let zipCode = String(datum.zipCode)
            
            var temperature:String = "No temperature data found."
            
            if let temp = datum.currentTemperature{
                temperature = String(format: "%.1f", temp) + "°"
            }
            
            // create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = zipCode
            annotation.subtitle = temperature
            
            // place the annotation in an array of annotations
            annotations.append(annotation)
        }
        
        // add the annotations to the map
        self.mapView.addAnnotations(annotations)
    }
    
    
}

