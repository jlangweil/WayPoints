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


class AddWaypointTableViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var locationIdentified: Bool = false
    var locationManager = CLLocationManager()
    var wayPointCoordinate: CLLocationCoordinate2D?
    var wayPointAltitudeInFeet: CLLocationDistance?
    var wayPointPlaceMark: CLPlacemark? {
        didSet {
            if let city = wayPointPlaceMark!.locality, let state = wayPointPlaceMark!.administrativeArea {
                self.cityStateLabel.text = "\(city), \(state)"
            }
        }
    }
   
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var wayPointDescription: UITextView!
    @IBOutlet weak var charactersRemainingLabel: UILabel!
    @IBOutlet weak var urgentSwitch: UISwitch!
    @IBOutlet weak var turbulenceSelection: UISegmentedControl!
    @IBOutlet weak var icingSelection: UISegmentedControl!
    @IBOutlet weak var precipitationSelection: UISegmentedControl!
    @IBOutlet weak var imageViewCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wayPointDescription.layer.borderColor = UIColor.black.cgColor
        wayPointDescription.layer.borderWidth = 1.0
        altitudeLabel.text = "NO GPS POSITION"
        coordinatesLabel.text = "NO GPS POSITION"
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // set delgates
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        self.wayPointDescription.delegate=self
        locationManager.delegate=self
        // get location
        setupCoreLocation()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableLocationServices()
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
        if wayPointCoordinate == nil {
            displayNoGpsAlert()
            return
        }
        if imageView.image == nil {
            imageView.image = UIImage(named: "default")
        }
        let turbulence = Severity(rawValue: turbulenceSelection.titleForSegment(at: turbulenceSelection.selectedSegmentIndex)!)
        let icing = Severity(rawValue: icingSelection.titleForSegment(at: icingSelection.selectedSegmentIndex)!)
        let precipitation = Precip(rawValue: precipitationSelection.titleForSegment(at: precipitationSelection.selectedSegmentIndex)!)
        let urgent = urgentSwitch.isOn
        let utcTime = "\(Date().currentDate) \(Date().preciseGMTTime)Z"
        var altitude: String
        if wayPointAltitudeInFeet == nil {
            altitude = "Altitude unknown"
        }
        else {
            altitude = "\(wayPointAltitudeInFeet!)"
        }
        let city = wayPointPlaceMark?.locality
        let state = wayPointPlaceMark?.administrativeArea
        // TODO disable save button if GPS not working, allow to select own location/alt
        let annotation = WayPointAnnotation(coordinate: wayPointCoordinate!, title: "Username @ \(Int(wayPointAltitudeInFeet!))ft", subtitle: wayPointDescription.text, photo: imageView.image, time:utcTime, turbulence: turbulence!, icing: icing!, precipitation: precipitation!, urgent: urgent, city: city, state: state, altitude: altitude, id: nil)
        // save to database
        let key = saveAnnotationToDatabase(annotation)
        if imageView.image != nil {
            saveImageToDatabase(image: imageView.image!, key: key)
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
        let fireBaseWayPoint = waypoint.getDictionaryForDatabase(key)
        rootRef.child(key).setValue(fireBaseWayPoint)
        return key
    }
    
    func saveImageToDatabase(image:UIImage, key:String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        //let keyRef = storageRef.child("\(key).jpg")
        let imagesRef = storageRef.child("images/\(key).jpg")
        // Data in memory
        if let data = UIImageJPEGRepresentation(image, 1.0) as Data? {
           
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = imagesRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print(error.debugDescription)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
            }
            
        }
    }
    
    func saveImageToCache(image:UIImage, key:String) {
        
    }
    
    func displayNoGpsAlert() {
        let alert = UIAlertController(title: "Warning", message: "Unable to save - NO GPS Signal", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        wayPointDescription.resignFirstResponder()
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
        locationIdentified = true
        wayPointCoordinate = location.coordinate
        wayPointAltitudeInFeet = location.altitude * 3.28084
        let altitudeInFeet = Int(wayPointAltitudeInFeet!)
        coordinatesLabel.text = "\(String(format: "%.5f", wayPointCoordinate!.latitude)), \(String(format: "%.5f", wayPointCoordinate!.longitude))"
        altitudeLabel.text = "\(altitudeInFeet) feet"
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil) {
                print("Error in reverseGeocode")
            }
            
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                if placemark.administrativeArea != nil && placemark.locality != nil {
                    self.wayPointPlaceMark = placemark
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
    
    // MARK textView delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        /*if(textView.text.characters.count > 20 && range.length == 0) {
         print("Please summarize in 20 characters or less")
         return false;
         }*/
        if numberOfChars < 281 {
            charactersRemainingLabel .text = String(280-numberOfChars)
        }
        return numberOfChars < 281;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    static let USDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter
    }()
}
extension Date {
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
    var currentDate: String {
        return Formatter.USDate.string(for: self) ?? ""
    }
}

