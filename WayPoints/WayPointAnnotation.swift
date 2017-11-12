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
    var photo:UIImage?
    var time:String?
    var turbulence:Severity
    var icing:Severity
    var precipitation:Precip
    var urgent:Bool = false
    
    init(coordinate:CLLocationCoordinate2D,title:String?,subtitle:String?, photo:UIImage?, time:String?, turbulence:Severity, icing: Severity, precipitation: Precip, urgent: Bool){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.photo = photo
        self.time = time
        self.turbulence = turbulence
        self.precipitation=precipitation
        self.icing = icing
        self.urgent = urgent
        
    }
}

