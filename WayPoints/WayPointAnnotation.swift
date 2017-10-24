//
//  WayPointAnnotation.swift
//  WayPoints
//
//  Created by apple on 10/20/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import Foundation
import MapKit

class WayPointAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var photo:UIImage! = nil
    init(coordinate:CLLocationCoordinate2D,title:String?,subtitle:String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

