//
//  AddWaypointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/9/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit
import Firebase


class AddWaypointTableViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var locationIdentified = false
    var locationManager = CLLocationManager()
    var reverseGeoCodeSucceeded = false
    var wayPointCoordinate: CLLocationCoordinate2D?
    var manual = false
    var wayPointAltitudeInFeet: CLLocationDistance?
    var wayPointPlaceMark: CLPlacemark? {
        didSet {
            if let city = wayPointPlaceMark!.locality, let state = wayPointPlaceMark!.administrativeArea {
                self.cityStateLabel.text = "\(city), \(state)"
                self.cityLocation = city
                self.stateLocation = state
            }
            else if let country=wayPointPlaceMark!.country {
                self.cityStateLabel.text = country
                self.stateLocation = country
            }
        }
    }
   
    //@IBOutlet weak var aircraftTypeTextView: UITextView!
    @IBOutlet weak var aircraftTypeTextField: UITextField!
    //@IBOutlet weak var registrationTextView: UITextView!
    @IBOutlet weak var registrationTextField: UITextField!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var wayPointDescription: UITextView!
    @IBOutlet weak var charactersRemainingLabel: UILabel!
    @IBOutlet weak var urgentSwitch: UISwitch!
    @IBOutlet weak var turbulenceSelection: UISegmentedControl!
    @IBOutlet weak var icingSelection: UISegmentedControl!
    @IBOutlet weak var cloudSelection: UISegmentedControl!
    @IBOutlet weak var precipitationSelection: UISegmentedControl!
    @IBOutlet weak var imageViewCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var altitudeStepper: UIStepper!
    @IBOutlet weak var nearestAirport: UILabel!
    
    @IBAction func altitudeChanged(_ sender: UIStepper) {
        let altitude = Int(sender.value)
        altitudeLabel.text = "\(altitude) ft"
        
    }
    
    var cityLocation: String?
    var stateLocation: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wayPointDescription.layer.borderColor = UIColor.black.cgColor
        wayPointDescription.layer.borderWidth = 1.0
        altitudeLabel.text = "NO GPS POSITION"
        coordinatesLabel.text = "NO GPS POSITION"
        if let reg=defaults.string(forKey: "defaultAircraftRegistration") {
            registrationTextField.text = reg
        }
        if let acType=defaults.string(forKey: "defaultAircraftType") {
            aircraftTypeTextField.text = acType
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // set delgates
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        self.wayPointDescription.delegate=self
        self.aircraftTypeTextField.delegate=self
        self.registrationTextField.delegate=self
        locationManager.delegate=self
        // get location
        if !manual {
            DispatchQueue.global().async { [weak self] in
                self?.setupCoreLocation()
            }
            
        }
        else
        {
            disableLocationServices()
            coordinatesLabel.text = "\(String(format: "%.5f", wayPointCoordinate!.latitude)), \(String(format: "%.5f", wayPointCoordinate!.longitude))"
            altitudeLabel.text = "0 ft"
            altitudeStepper.isHidden = false
            let location = CLLocation(latitude: wayPointCoordinate!.latitude, longitude: wayPointCoordinate!.longitude)
            setLocationUsingGeoCoder(location: location)
            nearestAirport.text = getAirportString(location: location)
        }
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !manual {
            disableLocationServices()
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate=self
        let alert = UIAlertController(title: "Choose source", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func saveWayPoint(_ sender: Any) {
        var imageAttached: Bool = true
        if wayPointCoordinate == nil {
            displayNoGpsAlert()
            return
        }
        if imageView.image == nil {
            imageAttached=false
            imageView.image = UIImage(named: "default")
        }
        let turbulence = Severity(rawValue: turbulenceSelection.titleForSegment(at: turbulenceSelection.selectedSegmentIndex)!)
        let icing = Severity(rawValue: icingSelection.titleForSegment(at: icingSelection.selectedSegmentIndex)!)
        let precipitation = Precip(rawValue: precipitationSelection.titleForSegment(at: precipitationSelection.selectedSegmentIndex)!)
        let clouds = cloudSelection.titleForSegment(at: cloudSelection.selectedSegmentIndex)
        let urgent = urgentSwitch.isOn
        let utcTime = "\(Date().preciseGMTDateTime)Z" //switch to timestamp?
        var altitude: String
        if manual {
            altitude = "\(Int(altitudeStepper.value))"
        }
        else {
            if wayPointAltitudeInFeet == nil {
                altitude = "-- ft"
            }
            else {
                altitude = "\(wayPointAltitudeInFeet!)"
            }
        }
        //let city = wayPointPlaceMark?.locality
        //let state = wayPointPlaceMark?.administrativeArea
        
        let aircraftType = aircraftTypeTextField.text ?? ""
        let aircraftRegistration = registrationTextField.text ?? ""
        
        var imageAspect: String?
        if imageAttached {
            let thumbnailSize = imageView.image!.getThumbnailSize()
            let ratio = thumbnailSize.width / thumbnailSize.height
            imageAspect = "\(ratio)"
        }
        
        let closestAirport = nearestAirport.text
        
        let annotation = WayPointAnnotation(coordinate: wayPointCoordinate!, title: "", subtitle: wayPointDescription.text, photo: imageView.image, time:utcTime, turbulence: turbulence!, icing: icing!, precipitation: precipitation!, clouds: clouds!, urgent: urgent, city: cityLocation, state: stateLocation, altitude: altitude, aircraftRegistration: aircraftRegistration, aircraftType: aircraftType, imageAspect:imageAspect, id: nil, userID: signedInUser, nearestAirport: closestAirport)
        // save to database
        let key = saveAnnotationToDatabase(annotation)
        if imageAttached {
            //saveImageToDatabase(image: imageView.image!, key: key, thumbnail: false)
            // save thumbnail
            let thumbnailSize = imageView.image!.getThumbnailSize()
            let thumbnailImage = imageView.image!.resizeImage(targetSize: thumbnailSize)
            saveImageToDatabase(image: thumbnailImage, key: key, thumbnail: true)
        }
       
        // Replacing this, map controller will handle seeing and adding waypoints only through the database observer
        /*let mapViewController = navigationController?.viewControllers[0] as! MapViewViewController
        // add annotation to the array
        mapViewController.waypoints.append(annotation)
        
        // update map
        mapViewController.updateMap()*/
        // TODO update tableview here as well
    
        navigationController?.popViewController(animated: true)
        
    }
    
    func saveAnnotationToDatabase(_ waypoint:WayPointAnnotation) -> String {
        // Add data to Firebase
        let rootRef = Database.database().reference().child("waypoints");
        let key = rootRef.childByAutoId().key
        var fireBaseWayPoint = waypoint.getDictionaryForDatabase(key)
        fireBaseWayPoint["timestamp"] = ServerValue.timestamp()
        rootRef.child(key).setValue(fireBaseWayPoint)
        return key
    }
    
    func saveImageToDatabase(image:UIImage, key:String, thumbnail:Bool) {
        pendingUploads += 1
        let storage = Storage.storage()
        let storageRef = storage.reference()
        //let keyRef = storageRef.child("\(key).jpg")
        var ext = ""
        if thumbnail {
            ext = "_thumb"
        }
        let imageName = "images/\(key)\(ext).jpg"
        let imageNameWithoutFolder = "\(key)\(ext).jpg"
        let imagesRef = storageRef.child(imageName)
        // Data in memory
        if let data = UIImageJPEGRepresentation(image, 0.5) as Data? {
            // Write to disc first
            saveImageToDisc(data: data, imageName: imageName)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = imagesRef.putData(data, metadata: metadata)
            /*{ (metadata, error) in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    print("Error uploading file \(key)\(ext).jpg: \(error.debugDescription)")
                    return
                }*/
            
           // write filename to userdefaults
            
            uploadTask.observe(.success) { snapshot in
               print ("SUCESSS UPLOAD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                // delete from disk
                deleteImage(imageName: imageNameWithoutFolder)
                pendingUploads -= 1
            }
        }
    }
    
    func displayNoGpsAlert() {
        let alert = UIAlertController(title: "Warning", message: "Unable to save - NO GPS Signal\nLong press on map to manually select location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        wayPointDescription.resignFirstResponder()
        aircraftTypeTextField.resignFirstResponder()
        registrationTextField.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: wayPointDescription) {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK Location methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            //setupCoreLocation()
            print("authorized")
        case .denied, .restricted:
            disableLocationServices()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        locationIdentified = true
        wayPointCoordinate = location.coordinate
        wayPointAltitudeInFeet = location.altitude * 3.28084
        let altitudeInFeet = Int(wayPointAltitudeInFeet!)
        coordinatesLabel.text = "\(String(format: "%.5f", wayPointCoordinate!.latitude)), \(String(format: "%.5f", wayPointCoordinate!.longitude))"
        altitudeLabel.text = "\(altitudeInFeet) feet"
        // GET position from closet airport
        nearestAirport.text = getAirportString(location: location)
        if !reverseGeoCodeSucceeded {
            setLocationUsingGeoCoder(location: location)
        }
    }
    
    func getAirportString(location: CLLocation) -> String {
        let closestAirport = getClosestAirport(location: location)
        let closestAirportName = closestAirport?.icao
        let distance = location.distance(from: closestAirport!.coordinate) * 0.000539957
        print("distance = \(distance)nm")
        let bearing = getBearing(fromPoint: closestAirport!.coordinate, toPoint: location)
        print("bearing = \(bearing) degrees")
        let direction = getCompassDirection(bearing: bearing)
        let airportString = "\(String(format: "%.1f", distance))nm \(direction) of \(closestAirportName!)"
        return airportString
    }
    
    func setLocationUsingGeoCoder(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {[weak self](placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode \(error.debugDescription)")
            }
            if placemarks != nil {
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
                    if (placemark.administrativeArea != nil && placemark.locality != nil) || placemark.country != nil {
                        self?.wayPointPlaceMark = placemark
                        self?.reverseGeoCodeSucceeded = true
                    }
                }
            }
        })
    }
    
    // MARK imagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        //imageView.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        //imageViewCell.sizeToFit()
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK textField delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString text: String) -> Bool {
        
        if textField.text != nil
        {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            
            if textField == registrationTextField {
                return numberOfChars < 7
            }
            else if textField == aircraftTypeTextField {
                return numberOfChars < 5
            }
            else {
                return true
            }
        }
        else {
            return true
        }
    }
    
    // MARK textView delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
    
        if numberOfChars < 281 {
            charactersRemainingLabel .text = String(280-numberOfChars)
        }
        return numberOfChars < 281;

       
    }

   // MARK Location Services

    func setupCoreLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // how do i get it to enable location services here?
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
}
