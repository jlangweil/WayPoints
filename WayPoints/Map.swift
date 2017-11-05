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
    
    init() {
        annotations.removeAll()
        // set up some test points
        var testCoordinate : CLLocationCoordinate2D
        testCoordinate = CLLocationCoordinate2D(latitude: 20.0, longitude: -70)
        var testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world1", subtitle: "This is another test", photo: nil)
        annotations.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -100)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test", photo: nil)
        annotations.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 40.0, longitude: -110)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test", photo: nil)
        annotations.append(testWayPoint)
        
    }
 
}
