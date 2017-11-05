//
//  WayPointTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointTableViewController: UITableViewController {

    var map = Map()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        print ("map items: \(map.annotations.count)")
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // be sure to reload if the model changes
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return map.annotations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wayPointCell", for: indexPath)
        let title = map.annotations[indexPath.row].title
        if let wayPointCell = cell as? WayPointCustomTableCell {
            wayPointCell.wayPointTableData = title  // replace this with a new datastructure for the whole waypoint
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
