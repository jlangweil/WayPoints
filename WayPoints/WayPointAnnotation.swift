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
    var id: String?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var photo:UIImage?
    var time:String
    var turbulence:Severity
    var icing:Severity
    var precipitation:Precip
    var clouds:String
    var urgent:Bool = false
    var altitude:String
    var latitude : Double
    var longitude : Double
    var city:String?
    var state:String?
    var aircraftRegistration:String
    var aircraftType:String
    var imageAspect:String?
    var userID:String?
    var nearestAirport: String?
    var timeTaken: String?  
    
    init(coordinate:CLLocationCoordinate2D, title:String?, subtitle:String?, photo:UIImage?, time:String, turbulence:Severity, icing: Severity, precipitation: Precip, clouds: String, urgent: Bool, city: String?, state: String?, altitude: String, aircraftRegistration: String, aircraftType:String, imageAspect:String?, id: String?, userID: String?, nearestAirport: String?){
        self.id=id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.photo = photo
        self.time = time
        self.turbulence = turbulence
        self.precipitation=precipitation
        self.icing = icing
        self.clouds = clouds
        self.urgent = urgent
        self.city = city
        self.state = state
        self.altitude = altitude
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.aircraftType = aircraftType
        self.aircraftRegistration = aircraftRegistration
        self.imageAspect = imageAspect
        self.userID = userID
        self.nearestAirport = nearestAirport
    }
    
    func getDictionaryForDatabase(_ key:String) -> [String:Any] {
        let description = subtitle ?? ""
       let waypoint = ["id":key,
                        "latitude": "\(latitude)" as String,
                        "longitude": "\(longitude)" as String,
                        "altitude": "\(altitude)" as String,
                        "city": city ?? "" as String,
                        "state": state ?? "" as String,
                        "description": description as String,
                        "time": time as String,
                        "turbulence": turbulence.rawValue as String,
                        "icing": icing.rawValue as String,
                        "precipitation": precipitation.rawValue as String,
                        "clouds": clouds,
                        "urgent": urgent as Bool,
                        "aircraft": aircraftRegistration,
                        "aircrafttype": aircraftType,
                        "imageAspect": imageAspect ?? "0" as String,
                        "userID": userID ?? "" as String,
                        "nearestAirport" : nearestAirport ?? "" as String
            ] as [String : Any]
        
        return waypoint
    }
    
    func getLocation() -> String {
        if city != nil && state != nil {
            if city!.count > 0 && state!.count > 0 {
                return "\(city!), \(state!)"
            }
            else {
                return "\(city!) \(state!)"
            }
        }
        else {
            return ""
        }
    }
    
}

