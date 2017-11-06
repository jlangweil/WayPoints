//
//  Map.swift
//  WayPoints
//
//  Created by apple on 10/19/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import Foundation
import MapKit

struct Map {
    var annotations : [WayPointAnnotation] = []//change to waypointannotation class
    
    // Probably do not need this class.  WayPointAnnotation is probably the real model, and an array of them can be retreived and passed between views.
    
    init() {
        annotations.removeAll()
        // set up some test points
        let testImage = UIImage(named: "default")
        var testCoordinate : CLLocationCoordinate2D
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -70)
        getPlacemark(forLocation: CLLocation(latitude: 30,longitude: -90)) { (placemark, error) in
           
            print("test: \( placemark?.administrativeArea)")
        }
        var testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world1", subtitle: "This is another test", photo: testImage, time:"12:00PM")
        annotations.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -100)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.  This one is a little bigger.  Lots of fog", photo: testImage, time:"12:00PM")
        annotations.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 40.0, longitude: -110)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.", photo: testImage, time:"12:00PM")
        annotations.append(testWayPoint)
        
    }
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
        
    }
 
}
