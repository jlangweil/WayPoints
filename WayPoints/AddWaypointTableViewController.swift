//
//  AddWaypointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/9/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit

class AddWaypointTableViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var locationIdentified: Bool = false
    var locationManager = CLLocationManager()
    var wayPointCoordinate: CLLocationCoordinate2D?
    var wayPointAltitudeInFeet: CLLocationDistance?
    
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
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wayPointDescription.layer.borderColor = UIColor.black.cgColor
        wayPointDescription.layer.borderWidth = 1.0
        altitudeLabel.text = "NO GPS POSITION"
        coordinatesLabel.text = "NO GPS POSITION"
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        
        // set delgates
        self.wayPointDescription.delegate=self
        locationManager.delegate=self
        // get location
        setupCoreLocation()  // NEED TO MOVE THIS TO A SEPARATE THREAD - It Is blocking button actions until done
        // Do any additional setup after loading the view.
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableLocationServices()
    }
    
    
    
    // MARK Location tasks
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
        locationIdentified = true
        wayPointCoordinate = location.coordinate
        wayPointAltitudeInFeet = location.altitude * 3.28084
        let altitudeInFeet = Int(wayPointAltitudeInFeet!)
        coordinatesLabel.text = "\(String(format: "%.5f", wayPointCoordinate!.latitude)), \(String(format: "%.5f", wayPointCoordinate!.longitude))"
        altitudeLabel.text = "\(altitudeInFeet) feet"
        var currentPlace : CLPlacemark?
        getPlacemark(forLocation: CLLocation(latitude: wayPointCoordinate!.latitude, longitude: wayPointCoordinate!.longitude)) { (placemark, error) in
            currentPlace = placemark
            if let currentCity = currentPlace?.locality, let currentState=currentPlace?.administrativeArea  {
                self.cityStateLabel.text = "\(currentCity), \(currentState)"
            }
            else {
                self.cityStateLabel.text = ""
            }
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
    
    // MARK imagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        //imageView.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        //imageViewCell.sizeToFit()
        dismiss(animated: true, completion: nil)
    }
    
    //override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        //return tableView.rowHeight
    //}

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
