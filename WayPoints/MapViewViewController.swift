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
    
    var startDate:Int?
    var endDate:Int?
    var startingDate = Date()
    var endingDate = Date()
    
    var datePickerContainer = UIView()
    
    var mapCenter : CLLocationCoordinate2D? {
        didSet {
            mapView.setCenter(mapCenter!, animated: true)
        }
    }
    
    var manualAdd = false
    
    @IBOutlet weak var timeDisplay: UILabel!
    
    @IBAction func showStreetView(_ sender: Any) {
       self.mapView.mapType = MKMapType.standard
    }
    
    @IBAction func showSatView(_ sender: Any) {
        self.mapView.mapType = MKMapType.satellite
    }
    
    @IBOutlet weak var timeFilter: UISegmentedControl!
    @IBAction func timeSelected(_ sender: Any) {
        setDateRanges()
        getWayPointsFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpCustomHistory()
        setDateRanges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultLatitude = 40.0
        let defaultLongitude = -74.0
        
        // set map bounds here if setting to do so is set
        let restoreMapPosition = defaults.bool(forKey: "saveMapPosition")
        print ("RestoreMapPosition=\(restoreMapPosition)")
        
        self.mapView.delegate=self
        let calendar = Calendar.current
        endingDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        setUpDatePicker()
        setDateRanges()
        
        if restoreMapPosition, defaults.object(forKey: "longitudeDelta") != nil {
            let savedCenterLatitude = defaults.double(forKey: "mapCenterLatitude")
            let savedCenterLongitude = defaults.double(forKey: "mapCenterLongitude")
            let savedLatitudeDelta = defaults.double(forKey: "latitudeDelta")
            let savedLongitudeDelta = defaults.double(forKey: "longitudeDelta")
            let span = MKCoordinateSpan(latitudeDelta: savedLatitudeDelta, longitudeDelta: savedLongitudeDelta)
            let savedCoord = CLLocationCoordinate2D(latitude: savedCenterLatitude, longitude: savedCenterLongitude)
            let region = MKCoordinateRegion(center: savedCoord, span: span)
            mapView.setRegion(region, animated: true)
        }
        else {
           mapCenter = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)
        }
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        mapView.addGestureRecognizer(longGesture)

        // Do any additional setup after loading the view.
        if waypoints.count == 0 {
            //populateTestData()
            getWayPointsFromDatabase()  // the listener set up here will be moved to the sign on or an earlier page later.
        }
    }
    
    func setUpCustomHistory() {
        if let history=defaults.string(forKey: "waypointhistory") {
            self.timeFilter.setTitle(history, forSegmentAt: 2)
        }
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .began {
            let point = sender.location(in: self.mapView)
            let coordinateTouched = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print("\(coordinateTouched.latitude), \(coordinateTouched.longitude)")
            doesUserWantToCreateAWayPoint(at: coordinateTouched)
        }

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let latitude = currentCenter.coordinate.latitude
        let longitude = currentCenter.coordinate.longitude
        let latitudeDelta = mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        //print ("Coordinates: \(latitude), \(longitude)  Radius=\(radius)")
        defaults.set(latitude, forKey: "mapCenterLatitude")
        defaults.set(longitude, forKey: "mapCenterLongitude")
        defaults.set(longitudeDelta, forKey: "longitudeDelta")
        defaults.set(latitudeDelta, forKey: "latitudeDelta")
        defaults.synchronize()
    }
    
    func setDateRanges() {
        // 0 = Today, 1 = 24 hrs, 2 = 1 week 3 = custom
        let selection = timeFilter.selectedSegmentIndex
        let calendar = Calendar.current
        var dateOption: String?
        self.endingDate = Date()
        switch selection {
        case 0:
            startingDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: endingDate)!
            endingDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endingDate)!
            datePickerContainer.isHidden=true
        case 1:
            startingDate = calendar.date(byAdding: Calendar.Component.hour, value: -24, to: endingDate)!
            datePickerContainer.isHidden=true
        case 2:
            // custom view based on default of 1 week, or selected option in settings
            dateOption = timeFilter.titleForSegment(at: selection)
            startingDate = getCustomStartingDate(dateOption!, endingDate: endingDate)
            //startingDate = calendar.date(byAdding: Calendar.Component.day, value: -7, to: endingDate)!
            datePickerContainer.isHidden=true
        default:
            showDatePicker()
            //startingDate = calendar.date(byAdding: Calendar.Component.hour, value: -6, to: endingDate)!
        }
        self.startDate = startingDate.toFirebaseTimestamp()
        self.endDate = endingDate.toFirebaseTimestamp()
        if dateOption == "All" {
            timeDisplay.text = "All available data"
        }
        else {
            timeDisplay.text = "\(startingDate.preciseGMTDateTime)Z - \(endingDate.preciseGMTDateTime)Z"
        }
        print("Start Timestamp: \(self.startDate!), End Timestamp: \(self.endDate!)")
    }
    
    func getCustomStartingDate(_ dateOption: String, endingDate: Date) -> Date {
        let calendar = Calendar.current
        var startingDate : Date
        switch dateOption {
            case "1 week":
                startingDate = calendar.date(byAdding: Calendar.Component.day, value: -7, to: endingDate)!
            case "2 weeks":
                startingDate = calendar.date(byAdding: Calendar.Component.day, value: -14, to: endingDate)!
            case "1 month":
                startingDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: endingDate)!
            case "2 months":
                startingDate = calendar.date(byAdding: Calendar.Component.month, value: -2, to: endingDate)!
            case "6 months":
                startingDate = calendar.date(byAdding: Calendar.Component.month, value: -6, to: endingDate)!
            case "1 year":
                startingDate = calendar.date(byAdding: Calendar.Component.year, value: -1, to: endingDate)!
            case "2 years":
                startingDate = calendar.date(byAdding: Calendar.Component.year, value: -2, to: endingDate)!
            case "All":
                startingDate = Date(timeIntervalSince1970: 0)
            default:
                startingDate = calendar.date(byAdding: Calendar.Component.day, value: -7, to: endingDate)!
            }
        return startingDate
    }
    
    func setUpDatePicker() {
        let datePicker : UIDatePicker = UIDatePicker()
        let viewWidth = self.view.frame.width
        datePickerContainer.frame = CGRect(x:0, y:80, width:viewWidth, height:250)
        datePickerContainer.backgroundColor = UIColor.white
        
        let pickerSize : CGSize = datePicker.sizeThatFits(CGSize.zero)
        
        
        datePicker.frame = CGRect(x:0, y:50, width:pickerSize.width, height:200)
        datePicker.setDate(Date(), animated: true)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: UIControlEvents.valueChanged)
        datePickerContainer.addSubview(datePicker)
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(dismissPicker), for: UIControlEvents.touchUpInside)
        doneButton.frame = CGRect(x:viewWidth-70-5, y:5, width:70, height:44)
        
        datePickerContainer.addSubview(doneButton)
        self.view.addSubview(datePickerContainer)
        datePickerContainer.isHidden=true
    }
    
    func showDatePicker() {
        datePickerContainer.isHidden=false
    }
    
    @objc func dismissPicker(sender: UIButton) {
        getWayPointsFromDatabase()
        self.datePickerContainer.isHidden=true
        self.timeFilter.selectedSegmentIndex = -1
    }// end dismissPicker
    
    @objc func dateChanged(_ sender: UIDatePicker){
        let calendar = Calendar.current
        startingDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: sender.date)!
        endingDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: sender.date)!
        self.startDate = startingDate.toFirebaseTimestamp()
        self.endDate = endingDate.toFirebaseTimestamp()
        timeDisplay.text = "\(startingDate.currentDate)"
        print("Start Timestamp: \(self.startDate!), End Timestamp: \(self.endDate!)")
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
        
        if let waypointAnnotation = annotation as? WayPointAnnotation {
            var conditions: [String?] = []
            conditions.append(waypointAnnotation.turbulence.rawValue)
            conditions.append(waypointAnnotation.icing.rawValue)
            conditions.append(waypointAnnotation.precipitation.rawValue)
            let urgent = waypointAnnotation.urgent
            let pinImageName = getWaypointPinName(conditions: conditions, urgent: urgent)
            annotationView?.image = UIImage(named: pinImageName)
        }
        else {
            annotationView?.image = UIImage(named: "wayPointPinDefaultSmall")
        }
        
       
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
        /*let turbulenceImageName = getImageName(weather: "turbulence", severity: wayPointAnnotation.turbulence)
        let icingImageName = getImageName(weather: "icing", severity: wayPointAnnotation.icing)
        let weatherImageName = getImageName(precip: wayPointAnnotation.precipitation)*/
        
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.wayPointUsername.text = "\(wayPointAnnotation.altitude.getAltitudeAsInteger()) ft"
        calloutView.wayPointDescription.text = wayPointAnnotation.subtitle
        calloutView.wayPointDescription.layer.borderWidth = 1
        calloutView.wayPointDescription.layer.borderColor = UIColor.black.cgColor
        calloutView.timeLabel.text = wayPointAnnotation.time
        calloutView.location.text = wayPointAnnotation.getLocation()
        if wayPointAnnotation.urgent {
            calloutView.location.text = "\(calloutView.location.text!) 🚨"
        }
        calloutView.turbStatus.text = getTextForSeverity(severity: wayPointAnnotation.turbulence)
        calloutView.turbStatus.layer.backgroundColor = getBackgroundColorForSeverity(severity: wayPointAnnotation.turbulence).cgColor
        calloutView.icingStatus.text = getTextForSeverity(severity: wayPointAnnotation.icing)
        calloutView.icingStatus.layer.backgroundColor = getBackgroundColorForSeverity(severity: wayPointAnnotation.icing).cgColor
        let precipImageName = getImageName(precip: wayPointAnnotation.precipitation)
        if precipImageName != nil {
            calloutView.precipImage.image = UIImage(named: precipImageName!)
        }
        calloutView.skyStatus.text = wayPointAnnotation.clouds
        var acType=""
        if wayPointAnnotation.aircraftType != "" {
            acType = " (\(wayPointAnnotation.aircraftType))"
        }
        calloutView.userLabel.text = "\(wayPointAnnotation.aircraftRegistration)\(acType)"
        
        if let cachedImage = imageCache.object(forKey: wayPointAnnotation.id! as NSString) {
            print("got cached image")
            calloutView.wayPointImage.image = cachedImage
        }
        else {
            // Reference to an image file in Firebase Storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            //let reference = storageRef.child("images/\(wayPointAnnotation.id!).jpg")
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
                                calloutView.wayPointImage.contentMode = .scaleAspectFit
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
            performSegue(withIdentifier: "showPhoto", sender: callOutImageView)
        }
    }
    
    func doesUserWantToCreateAWayPoint(at coordinate: CLLocationCoordinate2D) {
        self.mapCenter = coordinate
        let alert = UIAlertController(title: "Manual Waypoint", message: "Create a waypoint at this location?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            //print("User would like to create a waypoint here - \(coordinate.latitude), \(coordinate.longitude)")
            self.manualAdd=true
            self.performSegue(withIdentifier: "addNew", sender: coordinate)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // create object to pass in as sender and then pass to the destination.  for now just passing the image
        if let photoController = segue.destination as? WayPointPhotoViewController,let customImageView = sender as? UIImageView {
            photoController.image = customImageView.image
        }
        if let addWaypointController = segue.destination as? AddWaypointTableViewController {
            if self.manualAdd==true, let coordinate = sender as? CLLocationCoordinate2D {
                addWaypointController.wayPointCoordinate = coordinate
                addWaypointController.manual = true
            }
        }
    }
    
    func getWayPointsFromDatabase() {
        self.mapView.removeAnnotations(waypoints)
        waypoints.removeAll()
        let ref = Database.database().reference()
        ref.removeAllObservers()
        print(self.startDate!)
        print(self.endDate!)
        let wayPointsRef = ref.child("waypoints").queryOrdered(byChild: "timestamp").queryStarting(atValue: self.startDate).queryEnding(atValue: self.endDate)
        wayPointsRef.observe(DataEventType.childAdded, with: { [weak self] (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                print("Observer fired")
                let id = userDict["id"] as! String // Will be used to retrieve image
                let city = userDict["city"] as! String
                let altitude = userDict["altitude"] as! String
                let description = userDict["description"] as! String
                let state = userDict["state"] as! String
                let icing = userDict["icing"] as! String
                let clouds = userDict["clouds"] as? String ?? ""
                let latitude = userDict["latitude"] as! String
                let longitude = userDict["longitude"] as! String
                let precipitation = userDict["precipitation"] as! String
                let time = userDict["time"] as! String
                let turbulence = userDict["turbulence"] as! String
                let urgent = userDict["urgent"] as! Bool
                let aircraftRegistration = userDict["aircraft"] as? String ?? ""
                let aircraftType = userDict["aircrafttype"] as? String ?? ""
                let coordinateOfNewWayPoint = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let wayPointToBeAdded = WayPointAnnotation(coordinate: coordinateOfNewWayPoint, title: nil, subtitle: description, photo: nil, time: time, turbulence: Severity(rawValue: turbulence)!, icing: Severity(rawValue: icing)!, precipitation: Precip(rawValue: precipitation)!, clouds: clouds, urgent: urgent, city: city, state: state, altitude: altitude, aircraftRegistration: aircraftRegistration, aircraftType: aircraftType, id: id)
                self?.waypoints.append(wayPointToBeAdded) 
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
