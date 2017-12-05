//
//  WayPointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class WayPointTableViewController: UITableViewController, UISearchBarDelegate {

    //var map = Map()
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
        tableView.estimatedRowHeight=175
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // be sure to reload if the model changes
        //waypoints = getWayPointsFromMapView()
        //waypoints.reverse() // sort in most recent order
        gatherNewData()  //put this on another queue
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "WayPoints List"
    }
    
    private func getWayPointsFromMapView() -> [WayPointAnnotation]{
        if mapVC!.waypoints.count == 0 {
            mapVC!.getWayPointsFromDatabase()
        }
        return mapVC!.waypoints
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
            print("priority: \(snapshot.priority!)")
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
                let clouds = userDict["clouds"] as? String ?? ""
                let time = userDict["time"] as! String
                let turbulence = userDict["turbulence"] as! String
                let urgent = userDict["urgent"] as! Bool
                let coordinateOfNewWayPoint = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let wayPointToBeAdded = WayPointAnnotation(coordinate: coordinateOfNewWayPoint, title: nil, subtitle: description, photo: nil, time: time, turbulence: Severity(rawValue: turbulence)!, icing: Severity(rawValue: icing)!, precipitation: Precip(rawValue: precipitation)!, clouds: clouds, urgent: urgent, city: city, state: state, altitude: altitude, id: id)
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
                    //self?.tableView?.reloadData()
                    self?.tableView?.beginUpdates()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.tableView?.insertRows(at: [indexPath], with: .fade)
                    self?.tableView?.endUpdates()
                }
            }
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //return map.annotations.count
        return waypoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wayPointCell", for: indexPath)
        let id = waypoints[indexPath.row].id
        let description = waypoints[indexPath.row].subtitle
        var location = waypoints[indexPath.row].getLocation()
        if waypoints[indexPath.row].urgent {
            location = "\(location) 🚨"
        }
        let time = waypoints[indexPath.row].time
        let conditions = "Turbulence: \(waypoints[indexPath.row].turbulence.rawValue.uppercased())\nIcing: \(waypoints[indexPath.row].icing.rawValue.uppercased())\nPrecipitation: \(waypoints[indexPath.row].precipitation.rawValue.uppercased())\nClouds: \(waypoints[indexPath.row].clouds)"
        //let time = waypoints[indexPath.row].time.replacingOccurrences(of: " ", with: "\r\n")  // may want to separate datetime in database anyway for filtering query
        //let image = waypoints[indexPath.row].photo  // TODO: see if photo is nil.  If it is, check cache, then go to database.  Better-create thumbnails for smaller display
        var image : UIImage?
        // Set data without image
        if let wayPointCell = cell as? WayPointCustomTableCell {
            wayPointCell.imageID = id
            wayPointCell.spinner.startAnimating()
            let placeholder = UIImage(named: "placeholder")
            wayPointCell.wayPointTableData = WayPointCustomTableCellData(image: placeholder, time: time, location: location, description: description)
            wayPointCell.conditionsLabel.text = conditions
            if let cachedImage = imageCache.object(forKey: "\(id!)_thumb" as NSString) {
                wayPointCell.wayPointImageView.image = cachedImage
                wayPointCell.spinner.stopAnimating()
            }
            else {
                // move this to global file later
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let reference = storageRef.child("images/\(id!)_thumb.jpg")
                reference.downloadURL { url, error in
                    if let error = error {
                        // Handle any errors
                        print("Could not retrieve image: \(error.localizedDescription)")
                        if let wayPointCell = cell as? WayPointCustomTableCell {
                            wayPointCell.spinner.stopAnimating()
                        }
                    }
                    else {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let urlContents = try? Data(contentsOf: url!)
                            if let imageData = urlContents {
                                image = UIImage(data: imageData)
                                imageCache.setObject(image!, forKey: "\(id!)_thumb" as NSString)
                            }
                            DispatchQueue.main.async {
                                if let wayPointCell = cell as? WayPointCustomTableCell {
                                    wayPointCell.wayPointImageView.image = image
                                    wayPointCell.spinner.stopAnimating()
                                    // Add gesture to image
                                    let handler = #selector(self.openImage(byReactingTo:))
                                    let tapRecognizer = UITapGestureRecognizer(target: self, action: handler)
                                    tapRecognizer.numberOfTapsRequired=1
                                    wayPointCell.wayPointImageView.isUserInteractionEnabled=true
                                    wayPointCell.wayPointImageView.addGestureRecognizer(tapRecognizer)
                                }
                            }
                        }
                    }
                }
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
    
    /*func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTerm = nil
        waypoints = copyOfWayPointsForSearch
        self.tableView.reloadData()
    }*/
    
    func filterSearch() {
        waypoints = waypoints.filter { ($0.city?.contains(find: searchTerm!) ?? false) || ($0.state?.contains(find: searchTerm!) ?? false) || $0.description.contains(find: searchTerm!)}
        self.tableView.reloadData()
    }
    
    func cancelSearch() {
        
    }
    
    
    // MARK SEGUE
    
    @objc func openImage(byReactingTo tapRecognizer : UITapGestureRecognizer)
    {
      if let imageView = tapRecognizer.view as? UIImageView {
            if let cell = imageView.superview?.superview as? WayPointCustomTableCell {
                let imageID = cell.imageID!
                performSegue(withIdentifier: "showPhoto", sender: imageID)
            }
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the ImageID for the full sized image to the photo controller to load
        if let photoController = segue.destination as? WayPointPhotoViewController,let imageID = sender as? String {
            photoController.idOfImageToLoad = imageID
        }
    }

}
