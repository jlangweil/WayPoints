//
//  MapViewViewController.swift
//  WayPoints
//
//  Created by apple on 10/19/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {

    var mapCenter : CLLocationCoordinate2D? {
        didSet {
            mapView.setCenter(mapCenter!, animated: true)
        }
    }
    
    var mapData = Map()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up some sample data for now, get from Model later
        let latitude = 40.0
        let longitude = -74.0
        // set up some sample annotations
        //let range = 1000.0
        mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Do any additional setup after loading the view.
        mapView.addAnnotations(mapData.annotations)
        
        // use the mapData object to populate the points in the map
    }

    @IBOutlet weak var mapView: MKMapView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
