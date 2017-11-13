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

    // The Model
    var waypoints : [WayPointAnnotation] = []
    
    var mapCenter : CLLocationCoordinate2D? {
        didSet {
            mapView.setCenter(mapCenter!, animated: true)
        }
    }
    
    //fileprivate var callOutImage : UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "WayPoints Map"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adjust fonts

        // set up some sample data for now, get from Model later
        let latitude = 40.0
        let longitude = -74.0
        self.mapView.delegate=self
        
        mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // Do any additional setup after loading the view.
        if waypoints.count == 0 {
            populateTestData()
        }
        // here is where we will get the data from the database based on a filter
        updateMap()
    }
    
    public func updateMap() {
        mapView.addAnnotations(waypoints)
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
        //annotationView?.image = UIImage(named: "plane")
        annotationView?.image = UIImage(named: "wayPointPinDefaultSmall")
       
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
        let turbulenceImageName = getImageName(weather: "turbulence", severity: wayPointAnnotation.turbulence)
        let icingImageName = getImageName(weather: "icing", severity: wayPointAnnotation.icing)
        let weatherImageName = getImageName(precip: wayPointAnnotation.precipitation)
        
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.wayPointUsername.text = wayPointAnnotation.title
        calloutView.wayPointDescription.text = wayPointAnnotation.subtitle
        calloutView.timeLabel.text = wayPointAnnotation.time
        
        // Set Callout Images
        calloutView.wayPointImage.image = wayPointAnnotation.photo
        if turbulenceImageName != nil {
            calloutView.turbulanceImageView.image = UIImage(named: turbulenceImageName!)
        }
        if icingImageName != nil {
            calloutView.icingImageView.image = UIImage(named: icingImageName!)
        }
        if weatherImageName != nil {
            calloutView.wxImageView.image = UIImage(named: weatherImageName!)
        }
        
        // Resize callout relative to screen width
        let resizedWidth = mapView.frame.width * 0.9
        calloutView.frame.size = CGSize(width: resizedWidth, height: resizedWidth/2.418)
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        
        // Add gesture to callout image
        let handler = #selector(self.openImage(byReactingTo:))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: handler)
        tapRecognizer.numberOfTapsRequired=1
        calloutView.wayPointImage.isUserInteractionEnabled=true
        calloutView.wayPointImage.addGestureRecognizer(tapRecognizer)
        
        calloutView.layer.borderWidth=3
        calloutView.layer.borderColor = UIColor.black.cgColor
        
        
        // add custom callout view to annotation and recenter map
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    @objc func openImage(byReactingTo tapRecognizer : UITapGestureRecognizer)
    {
        if let callOutImageView = tapRecognizer.view as? UIImageView {
            //callOutImage = callOutImageView.image
            performSegue(withIdentifier: "showPhoto", sender: callOutImageView)
        }
    }
    
    // Used to get the city,state of the coordinate
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
   /* override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // create object to pass in as sender and then pass to the destination.  for now just passing the image
        if let photoController = segue.destination as? WayPointPhotoViewController,let customImageView = sender as? UIImageView {
            photoController.image = customImageView.image
        }
    }
    
    private func populateTestData() {
        waypoints.removeAll()
        
        // set up some test points
        /*testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -70)
        getPlacemark(forLocation: CLLocation(latitude: 30,longitude: -90)) { (placemark, error) in
            
            print("test: \( placemark?.administrativeArea)")
        }*/
        let testImage = UIImage(named: "default")
        var testCoordinate : CLLocationCoordinate2D
        let precip: Precip = .rain
        let icing: Severity = .none
        let turbulence: Severity = .none
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -70)
        var testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world1", subtitle: "This is another test", photo: testImage, time:"12:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false)
        waypoints.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -100)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.  This one is a little bigger.  Lots of fog", photo: testImage, time:"12:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false)
        waypoints.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 40.0, longitude: -110)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.", photo: testImage, time:"1:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false)
        waypoints.append(testWayPoint)
    }
    
   
  

}
