//
//  MapViewViewController.swift
//  WayPoints
//
//  Created by apple on 10/19/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapViewViewController: UIViewController, MKMapViewDelegate {

    // The Model
    var waypoints : [WayPointAnnotation] = []
    
    var mapCenter : CLLocationCoordinate2D? {
        didSet {
            mapView.setCenter(mapCenter!, animated: true)
        }
    }
    
   
    @IBAction func showStreetView(_ sender: Any) {
       self.mapView.mapType = MKMapType.standard
    }
    
    @IBAction func showSatView(_ sender: Any) {
        self.mapView.mapType = MKMapType.satellite
    }
    
    @IBOutlet weak var timeFilter: UISegmentedControl!
    
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
            //populateTestData()
            getWayPointsFromDatabase()  // the listener set up here will be moved to the sign on or an earlier page later.
        }
    }
    
    /*public func updateMap() {
        mapView.addAnnotations(waypoints)
    }*/

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
        
        if let cachedImage = imageCache.object(forKey: wayPointAnnotation.id! as NSString) {
            calloutView.wayPointImage.image = cachedImage
        }
        else {
            // Reference to an image file in Firebase Storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let reference = storageRef.child("images/\(wayPointAnnotation.id!).jpg")
            
            // Fetch the download URL
            calloutView.spinner.startAnimating()
            
            reference.downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    print("Could not retrieve image: \(error.localizedDescription)")
                    calloutView.wayPointImage.image = UIImage(named: "default")
                    calloutView.spinner.stopAnimating()
                }
                else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let urlContents = try? Data(contentsOf: url!)
                        if let imageData = urlContents {
                            DispatchQueue.main.async {
                                // MAIN QUEUE
                                let downloadedImage = UIImage(data: imageData)
                                calloutView.wayPointImage.image = downloadedImage
                                // add to current waypoint
                                wayPointAnnotation.photo = downloadedImage // add to waypoint if viewed on map or get from cache?
                                // add to cache
                                imageCache.setObject(downloadedImage!, forKey: wayPointAnnotation.id! as NSString)
                                calloutView.spinner.stopAnimating()
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                calloutView.wayPointImage.image = UIImage(named: "default")
                            }
                        }
                    }
                }
            }
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // create object to pass in as sender and then pass to the destination.  for now just passing the image
        if let photoController = segue.destination as? WayPointPhotoViewController,let customImageView = sender as? UIImageView {
            photoController.image = customImageView.image
        }
    }
    
    func getWayPointsFromDatabase() {
        waypoints.removeAll()
        // GET EVERYTHING FOR NOW
        let ref = Database.database().reference()
        let wayPointsRef = ref.child("waypoints").queryOrdered(byChild: "time")
        wayPointsRef.observe(DataEventType.childAdded, with: { [weak self] (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let id = userDict["id"] as! String // Will be used to retrieve image
                let city = userDict["city"] as! String
                let altitude = userDict["altitude"] as! String
                let description = userDict["description"] as! String
                let state = userDict["state"] as! String
                let icing = userDict["icing"] as! String
                
                let latitude = userDict["latitude"] as! String
                let longitude = userDict["longitude"] as! String
                let precipitation = userDict["precipitation"] as! String
                let time = userDict["time"] as! String
                let turbulence = userDict["turbulence"] as! String
                let urgent = userDict["urgent"] as! Bool
                let coordinateOfNewWayPoint = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let wayPointToBeAdded = WayPointAnnotation(coordinate: coordinateOfNewWayPoint, title: nil, subtitle: description, photo: nil, time: time, turbulence: Severity(rawValue: turbulence)!, icing: Severity(rawValue: icing)!, precipitation: Precip(rawValue: precipitation)!, urgent: urgent, city: city, state: state, altitude: altitude, id: id)
                self?.waypoints.append(wayPointToBeAdded) // do I need the array of annotations?  Going to add directly to the map in each view.  Might remove this []
                // here is where we will get the data from the database based on a filter
                self?.mapView.addAnnotation(wayPointToBeAdded)
            }
        })
    }
    
    private func populateTestData() {
        waypoints.removeAll()
        
        // set up some test points
        /*testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -70)
        getPlacemark(forLocation: CLLocation(latitude: 30,longitude: -90)) { (placemark, error) in
            
            print("test: \( placemark?.administrativeArea)")
        }*/
        /*let testImage = UIImage(named: "default")
        var testCoordinate : CLLocationCoordinate2D
        let precip: Precip = .rain
        let icing: Severity = .none
        let turbulence: Severity = .none
        let altitude = "1000"
        let cityState = "Someplace, USA"
        testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -70)
        var testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world1", subtitle: "This is another test", photo: testImage, time:"12:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false, cityState: cityState, altitude: altitude)
        waypoints.append(testWayPoint)*/
        /*testCoordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -100)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.  This one is a little bigger.  Lots of fog", photo: testImage, time:"12:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false)
        waypoints.append(testWayPoint)
        testCoordinate = CLLocationCoordinate2D(latitude: 40.0, longitude: -110)
        testWayPoint = WayPointAnnotation(coordinate: testCoordinate, title: "Hello world2", subtitle: "This is another test.", photo: testImage, time:"1:00PM", turbulence: turbulence, icing: icing, precipitation: precip, urgent:false)
        waypoints.append(testWayPoint)*/
        
        // try to add data to Firebase
       // let rootRef = Database.database().reference().child("waypoints");
        //let key = rootRef.childByAutoId().key
        
        //creating artist with the given values
        //let waypoint = ["id":key,
         //             "latitude": "40.0" as String,
        //              "longitude": "-75.0" as String
        //]
        
        //adding the artist inside the generated unique key
       // rootRef.child(key).setValue(waypoint)
       
        
    }
    
   
  

}
