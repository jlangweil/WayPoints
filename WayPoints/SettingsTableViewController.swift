//
//  SettingsTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/14/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var saveMapPositionSwitch: UISwitch!
    @IBOutlet weak var defaultAirplane: UILabel!
    @IBOutlet weak var displayHistoryLabel: UILabel!
    
    
    @IBAction func switchMapPosition(_ sender: Any) {
        defaults.set(saveMapPositionSwitch.isOn, forKey: "saveMapPosition")
        defaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let saveMapPositionDefault = defaults.bool(forKey: "saveMapPosition")
        saveMapPositionSwitch.isOn = saveMapPositionDefault
        updateUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        if let reg=defaults.string(forKey: "defaultAircraftRegistration") {
            defaultAirplane.text = reg
        }
        if let history=defaults.string(forKey: "waypointhistory") {
            displayHistoryLabel.text = history
        }
        else {
            displayHistoryLabel.text = "1 week"
        }
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
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

    
    // MARK: - Navigation

    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwind" {
            do {
                let authUI = FUIAuth.defaultAuthUI()
                try authUI!.signOut()
                return true
            }
            catch {
                print("Could not logout")
                return false
            }
        }
        else {
            return true
        }
    }
    

}
