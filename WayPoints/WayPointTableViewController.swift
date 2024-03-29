//
//  WayPointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import MapKit

class WayPointTableViewController: UITableViewController, UISearchBarDelegate {

    var waypoints : [WayPointAnnotation] = []
    var copyOfWayPointsForSearch: [WayPointAnnotation] = []
    var mapVC: MapViewViewController?
    var searchTerm: String?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate=self
        let tabController = self.tabBarController
        let navController = tabController?.viewControllers![0] as! UINavigationController
        mapVC = navController.topViewController as? MapViewViewController
        tableView.estimatedRowHeight=500
        tableView.rowHeight = UITableViewAutomaticDimension
        gatherNewData()  //put this on another queue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "WayPoints Feed"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    @IBAction func refreshData(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        sender.endRefreshing()
    }
    
    private func gatherNewData() {
        let ref = Database.database().reference()
        ref.removeAllObservers()
        let wayPointsRef = ref.child("waypoints").queryOrdered(byChild: "timestamp")  // how much data should we get / starting point???
        wayPointsRef.observe(DataEventType.childAdded, with: { [weak self] (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let id = userDict["id"] as! String
                let city = userDict["city"] as! String
                let altitude = userDict["altitude"] as! String
                let description = userDict["description"] as! String
                let state = userDict["state"] as! String
                let icing = userDict["icing"] as! String
                let latitude = userDict["latitude"] as! String
                let longitude = userDict["longitude"] as! String
                let precipitation = userDict["precipitation"] as! String
                let clouds = userDict["clouds"] as? String ?? ""
                let timestamp = userDict["timestamp"] as! Int
                let time = String(timestamp)
                let turbulence = userDict["turbulence"] as! String
                let urgent = userDict["urgent"] as! Bool
                let aircraftRegistration = userDict["aircraft"] as? String ?? ""
                let aircraftType = userDict["aircrafttype"] as? String ?? ""
                let coordinateOfNewWayPoint = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let imageAspect = userDict["imageAspect"] as? String ?? "0"
                let userID = userDict["userID"] as? String ?? ""
                let nearestAirport = userDict["nearestAirport"] as? String ?? ""
                let wayPointToBeAdded = WayPointAnnotation(coordinate: coordinateOfNewWayPoint, title: nil, subtitle: description, photo: nil, time: time, turbulence: Severity(rawValue: turbulence)!, icing: Severity(rawValue: icing)!, precipitation: Precip(rawValue: precipitation)!, clouds: clouds, urgent: urgent, city: city, state: state, altitude: altitude, aircraftRegistration: aircraftRegistration, aircraftType: aircraftType, imageAspect:imageAspect, id: id, userID: userID, nearestAirport: nearestAirport)
                if (self?.waypoints.contains(where: { (annotation) -> Bool in
                    if id==annotation.id {
                        return true
                    }
                    else {
                        return false
                    }
                }))!
                {}// do nothing}
                else {
                    self?.waypoints.insert(wayPointToBeAdded, at: 0)

                    self?.tableView?.beginUpdates()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.tableView?.insertRows(at: [indexPath], with: .fade)
                    self?.tableView?.endUpdates()
                }
            }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return waypoints.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wayPointCell", for: indexPath)
        let id = waypoints[indexPath.row].id
        let description = waypoints[indexPath.row].subtitle
        let citystate = waypoints[indexPath.row].getLocation()
        var location = waypoints[indexPath.row].nearestAirport
        if waypoints[indexPath.row].urgent {
            location = "\(location!) 🚨"
        }
        let time = waypoints[indexPath.row].time.timeSinceString()
        let altitude = waypoints[indexPath.row].altitude
        var conditions = ""
        if altitude != "" {
            conditions = "Altitude: \(altitude.getAltitudeAsInteger()) ft\n"
        }
        if waypoints[indexPath.row].turbulence != .none {
            conditions = "\(conditions)Turbulence: \(waypoints[indexPath.row].turbulence.rawValue.uppercased())\n"
        }
        if waypoints[indexPath.row].icing != .none {
            conditions = "\(conditions)Icing: \(waypoints[indexPath.row].icing.rawValue.uppercased())\n"
        }
        if waypoints[indexPath.row].precipitation != .none {
            conditions = "\(conditions)Precipitation: \(waypoints[indexPath.row].precipitation.rawValue.uppercased())\n"
        }
        if waypoints[indexPath.row].clouds != "" {
            conditions = "\(conditions)Clouds: \(waypoints[indexPath.row].clouds)"
        }

        if let wayPointCell = cell as? WayPointCustomTableCell {
            var imageExists = false
            let aspectRatio = waypoints[indexPath.row].imageAspect
            var heightConstraint = CGFloat(0.0)
            if aspectRatio != "0" {
                let aspectRatioAsCGFloat = CGFloat((aspectRatio! as NSString).floatValue)
                heightConstraint = CGFloat(self.tableView.bounds.width) / aspectRatioAsCGFloat
                imageExists = true
            }
            wayPointCell.imageHeightConstraint.constant = heightConstraint
            
            wayPointCell.imageID = id
            //wayPointCell.spinner.startAnimating()
            let placeholder = UIImage(named: "placeholder")
            wayPointCell.wayPointImageView.image = placeholder
            wayPointCell.wayPointTitleLabel.text = location
            wayPointCell.wayPointDescriptionLabel.text = description
            wayPointCell.conditionsLabel.text = conditions
            wayPointCell.aircraftLabel.text=waypoints[indexPath.row].aircraftRegistration
            wayPointCell.aircraftTypeLabel.text=waypoints[indexPath.row].aircraftType
            if citystate.trimmingCharacters(in: NSCharacterSet.whitespaces) == "" {
                wayPointCell.citystate.text = time
            }
            else {
                wayPointCell.citystate.text = "\(citystate) 𐄁 \(time)"
            }
            if imageExists {
                // check if exists locally first, use that, as image may not have saved yet
                let imagesPath = getDocumentsDirectory().appendingPathComponent("images")
                let url = imagesPath.appendingPathComponent("\(id!)_thumb.jpg")
                if fileExistsAtPath(url.path)
                {
                     print("File still exists locally!!!!!!!")
                     let localImage = UIImage(contentsOfFile: url.path)
                     wayPointCell.wayPointImageView.image = localImage
                }
                else {
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let reference = storageRef.child("images/\(id!)_thumb.jpg")
                    let placeholder = UIImage(named: "placeholder")
                    wayPointCell.wayPointImageView.sd_setImage(with: reference, placeholderImage: placeholder)
                }
                let handler = #selector(self.openImage(byReactingTo:))
                let tapRecognizer = UITapGestureRecognizer(target: self, action: handler)
                tapRecognizer.numberOfTapsRequired=1
                wayPointCell.wayPointImageView.isUserInteractionEnabled=true
                wayPointCell.wayPointImageView.addGestureRecognizer(tapRecognizer)
            }
        }
        return cell
    }

    // MARK SEARCHING
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Searching for: \(searchBar.text!)")
        searchTerm = searchBar.text
        copyOfWayPointsForSearch = waypoints
        filterSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            perform(#selector(hideKeyboardWithSearchBar(bar:)), with: searchBar, afterDelay: 0)
        }
    }
    
    @objc func hideKeyboardWithSearchBar(bar:UISearchBar) {
        bar.resignFirstResponder()
        searchTerm = nil
        if copyOfWayPointsForSearch.count > 0 {
            waypoints = copyOfWayPointsForSearch
            copyOfWayPointsForSearch.removeAll()
            self.tableView.reloadData()
        }
    }
    
    private func filterSearch() {
        waypoints = waypoints.filter { ($0.city?.contains(find: searchTerm!) ?? false) || ($0.state?.contains(find: searchTerm!) ?? false) || $0.subtitle?.contains(find: searchTerm!) ?? false || ($0.aircraftRegistration.contains(find: searchTerm!) || ($0.aircraftType.contains(find: searchTerm!)))}
        self.tableView.reloadData()
    }

    // MARK SEGUE
    
    @objc func openImage(byReactingTo tapRecognizer : UITapGestureRecognizer)
    {
        if let imageView = tapRecognizer.view as? UIImageView {
            performSegue(withIdentifier: "showPhoto", sender: imageView)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoController = segue.destination as? WayPointPhotoViewController,let imageView = sender as? UIImageView {
            photoController.image = imageView.image
        }
        
    }

}
