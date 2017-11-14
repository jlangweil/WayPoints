//
//  WayPointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointTableViewController: UITableViewController {

    //var map = Map()
    var waypoints : [WayPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //print ("map items: \(map.annotations.count)")
        tableView.estimatedRowHeight=104
        tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // be sure to reload if the model changes
        waypoints = getWayPointsFromMapView()
        
    }
    
    private func getWayPointsFromMapView() -> [WayPointAnnotation]{
        let tabController = self.tabBarController
        let navController = tabController?.viewControllers![0] as! UINavigationController
        let mapVC = navController.topViewController as! MapViewViewController
        return mapVC.waypoints
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
        let description = waypoints[indexPath.row].subtitle
        let location = waypoints[indexPath.row].cityState
        let time = waypoints[indexPath.row].time
        let image = waypoints[indexPath.row].photo
        //let turbulence = waypoints[indexPath.row]
        if let wayPointCell = cell as? WayPointCustomTableCell {
            let cellData = WayPointCustomTableCellData(image: image, time: time, location: location, description: description)
            wayPointCell.wayPointTableData = cellData
            // Add gesture to image
            let handler = #selector(self.openImage(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: handler)
            tapRecognizer.numberOfTapsRequired=1
            wayPointCell.wayPointImageView.isUserInteractionEnabled=true
            wayPointCell.wayPointImageView.addGestureRecognizer(tapRecognizer)
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
