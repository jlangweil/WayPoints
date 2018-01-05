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
        tableView.estimatedRowHeight=50
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        let saveMapPositionDefault = defaults.bool(forKey: "saveMapPosition")
        saveMapPositionSwitch.isOn = saveMapPositionDefault
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func updateUI() {
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
