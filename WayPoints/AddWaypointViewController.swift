//
//  AddWaypointViewController.swift
//  WayPoints
//
//  Created by apple on 10/16/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import MapKit

class AddWaypointViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var waypointDescription: UITextView!
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        waypointDescription.resignFirstResponder()
    }
    
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var altitudeValue: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var remainingCharacters: UILabel!
    
    var locationIdentified: Bool = false
    
    @IBAction func getPhoto(_ sender: Any) {
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
        /*if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)*/
        

    }
    
    
    var locationManager = CLLocationManager()
    var wayPointCoordinate: CLLocationCoordinate2D?
    var wayPointAltitudeInFeet: CLLocationDistance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add a WayPoint"
        altitudeValue.text = "NO GPS POSITION"
        locationValue.text = "NO GPS POSITION"
        // set delgates
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
        // TODO disable save button if GPS not working, allow to select own location/alt
        let annotation = WayPointAnnotation(coordinate: wayPointCoordinate!, title: "Username @ \(Int(wayPointAltitudeInFeet!))ft", subtitle: waypointDescription.text, photo: imageView.image)
        let mapView = segue.destination as! MapViewViewController
        // add annotation to the array
        mapView.mapData.annotations.append(annotation)
        // save to database
    }
    
    // MARK keyboard related items
    
    // MARK SCROLLVIEW related items/gestures
    
    // MARK imagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image=image
        dismiss(animated: true, completion: nil)
    }
    
    // MARK textView delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        /*if(textView.text.characters.count > 20 && range.length == 0) {
            print("Please summarize in 20 characters or less")
            return false;
        }*/
        if numberOfChars < 141 {
            remainingCharacters.text = String(140-numberOfChars)
        }
        return numberOfChars < 141;
    }
    
    
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
        locationValue.text = "\(String(format: "%.5f", wayPointCoordinate!.latitude)), \(String(format: "%.5f", wayPointCoordinate!.longitude))"
        altitudeValue.text = "\(altitudeInFeet) feet"
        
    }
    
    
   

}
