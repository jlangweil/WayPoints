//
//  MapViewViewController.swift
//  WayPoints
//
//  Created by apple on 10/19/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController, MKMapViewDelegate {

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
        self.mapView.delegate=self
        // set up some sample annotations
        //let range = 1000.0
        mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Do any additional setup after loading the view.
        mapView.addAnnotations(mapData.annotations)
        
        // use the mapData object to populate the points in the map
    }

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK Annotations handlers
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "waypointpin")
        // TODO: Make sure pin is transparent
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        if view.annotation is MKUserLocation
        {
            return
        }
        let wayPointAnnotation = view.annotation as! WayPointAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.wayPointUsername.text = wayPointAnnotation.title
        calloutView.wayPointDescription.text = wayPointAnnotation.subtitle
        calloutView.wayPointImage.image = wayPointAnnotation.photo
        //let button = UIButton(frame: calloutView.starbucksPhone.frame)
        //button.addTarget(self, action: #selector(ViewController.callPhoneNumber(sender:)), for: .touchUpInside)
        //calloutView.addSubview(button)
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
