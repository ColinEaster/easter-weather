//
//  SecondViewController.swift
//  Easter Weather
//
//  Created by Colin Easter on 5/9/16.
//  Copyright © 2016 Colin Easter. All rights reserved.
//

import UIKit
import MapKit

class SecondViewController: UIViewController, MKMapViewDelegate {
    
    let sharedData = SharedData.sharedInstance
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        sharedData.data = SharedData.sharedInstance.data
        print("in second view controller")
        print(sharedData.data.count)
        
        print("loading second view controller")
        print(sharedData.data.count)
        
        mapView.delegate = self
        
        var annotations = [MKPointAnnotation]()
        print(sharedData.data.count)
        for datum in sharedData.data {
            
            // skip this entry if it doesn't have a lat/long
            guard let lat = datum.latitude, long = datum.longitude else{
                continue
            }
            
            print("past guard")
            print(lat)
            print(long)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let zipCode = String(datum.zipCode)
            
            var temperature:String = "No temperature data found."
            
            if let temp = datum.currentTemperature{
                temperature = String(format: "%.1f", temp) + "°"
            }
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = zipCode
            annotation.subtitle = temperature
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

