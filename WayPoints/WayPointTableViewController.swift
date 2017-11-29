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

class WayPointTableViewController: UITableViewController {

    //var map = Map()
    var waypoints : [WayPointAnnotation] = [] 
    var mapVC: MapViewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabController = self.tabBarController
        let navController = tabController?.viewControllers![0] as! UINavigationController
        mapVC = navController.topViewController as? MapViewViewController
        
        tableView.estimatedRowHeight=125
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
                let time = userDict["time"] as! String
                let turbulence = userDict["turbulence"] as! String
                let urgent = userDict["urgent"] as! Bool
                let coordinateOfNewWayPoint = CLLocationCoordinate2D(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let wayPointToBeAdded = WayPointAnnotation(coordinate: coordinateOfNewWayPoint, title: nil, subtitle: description, photo: nil, time: time, turbulence: Severity(rawValue: turbulence)!, icing: Severity(rawValue: icing)!, precipitation: Precip(rawValue: precipitation)!, urgent: urgent, city: city, state: state, altitude: altitude, id: id)
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
        let location = waypoints[indexPath.row].getLocation()
        let time = waypoints[indexPath.row].time
        //let time = waypoints[indexPath.row].time.replacingOccurrences(of: " ", with: "\r\n")  // may want to separate datetime in database anyway for filtering query
        //let image = waypoints[indexPath.row].photo  // TODO: see if photo is nil.  If it is, check cache, then go to database.  Better-create thumbnails for smaller display
        var image : UIImage?
        // Set data without image
        if let wayPointCell = cell as? WayPointCustomTableCell {
            wayPointCell.spinner.startAnimating()
            let placeholder = UIImage(named: "placeholder")
            wayPointCell.wayPointTableData = WayPointCustomTableCellData(image: placeholder, time: time, location: location, description: description)
            if let cachedImage = imageCache.object(forKey: id! as NSString) {
                wayPointCell.wayPointImageView.image = cachedImage
                wayPointCell.spinner.stopAnimating()
            }
            else {
                // move this to global file later
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let reference = storageRef.child("images/\(id!).jpg")
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
                                imageCache.setObject(image!, forKey: id! as NSString)
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
    
    @objc func openImage(byReactingTo tapRecognizer : UITapGestureRecognizer)
    {
        if let imageView = tapRecognizer.view as? UIImageView {
            //callOutImage = callOutImageView.image
            performSegue(withIdentifier: "showPhoto", sender: imageView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // create object to pass in as sender and then pass to the destination.  for now just passing the image
        if let photoController = segue.destination as? WayPointPhotoViewController,let customImageView = sender as? UIImageView {
            photoController.image = customImageView.image
        }
    }

}
