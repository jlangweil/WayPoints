//
//  SettingsDisplayHistoryTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/14/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class SettingsDisplayHistoryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate=self
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title="Waypoint Display History"
        setDefaultValue()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clearAllCheckMarks()
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        if let optionSelected = cell?.reuseIdentifier {
            defaults.set(optionSelected, forKey: "waypointhistory")
            defaults.synchronize()
        }
    }
    
    private func clearAllCheckMarks() {
        let numOfRows = tableView.numberOfRows(inSection: 0)
        for i in 0..<numOfRows {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
    
    private func setDefaultValue() {
        clearAllCheckMarks()
        if let defaultHistory = defaults.string(forKey: "waypointhistory") {
            let numOfRows = tableView.numberOfRows(inSection: 0)
            for i in 0..<numOfRows {
                let indexPath = IndexPath(row: i, section: 0)
                let cell = tableView.cellForRow(at: indexPath)
                if cell?.reuseIdentifier == defaultHistory {
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }
        }
        else {
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            if let optionSelected = cell?.reuseIdentifier {
                defaults.set(optionSelected, forKey: "waypointhistory")
                defaults.synchronize()
            }
            
        }
    }

}
