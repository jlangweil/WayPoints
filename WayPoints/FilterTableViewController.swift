//
//  FilterTableViewController.swift
//  WayPoints
//
//  Created by apple on 1/21/18.
//  Copyright © 2018 jel enterprises. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight=800
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func apply(_ sender: UIButton) {
        self.presentingViewController!.dismiss(animated: false, completion: nil)
    }
    

}
