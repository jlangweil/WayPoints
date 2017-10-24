//
//  AddWaypointViewController.swift
//  WayPoints
//
//  Created by apple on 10/16/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit

class AddWaypointViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var waypointDescription: UITextView!
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        waypointDescription.resignFirstResponder()
    }
    var locationManager = CLLocationManager()
    var wayPointCoordinate: CLLocationCoordinate2D?
    var wayPointAltitudeInMeters: CLLocationDistance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waypointDescription.delegate=self
        locationManager.delegate=self
        // get location
        setupCoreLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableLocationServices()
    }
    
    // doSave action and pop up dialog and remain on page, or segue?
    // wait to enable button until have location? either from GPS or some UI element
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //only one segue for now
        //let testCoordinate = CLLocationCoordinate2D(latitude: 44.0, longitude: -73)
        //disableLocationServices()
        let annotation = WayPointAnnotation(coordinate: wayPointCoordinate!, title: "Title", subtitle: waypointDescription.text)
        let mapView = segue.destination as! MapViewViewController
        // add annotation to the array
        mapView.mapData.annotations.append(annotation)
        
    }
    
    // MARK keyboard related items
    
    // MARK SCROLLVIEW related items/gestures
    
    // MARK Location methods
    func setupCoreLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            enableLocationServices()
        default:
            break
        }
    }
    
    func enableLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func disableLocationServices() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("authorized")
            case .denied, .restricted:
                print("denied")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        wayPointCoordinate = location.coordinate
        wayPointAltitudeInMeters = location.altitude
    }
    
    
   

}
