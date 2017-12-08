//
//  SettingsAircraftTableViewController.swift
//  WayPoints
//
//  Created by apple on 11/14/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class SettingsAircraftTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var aircraftRegTextField: UITextField!
    @IBOutlet weak var aircraftTypeTextField: UITextField!
    @IBAction func setAircraftReg(_ sender: UITextField) {
        defaults.set(sender.text!, forKey: "defaultAircraftRegistration")
        defaults.synchronize()
    }
    @IBAction func setAircraftType(_ sender: UITextField) {
        defaults.set(sender.text!, forKey: "defaultAircraftType")
        defaults.synchronize()
    }
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            return text.count < 6
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight=50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.title = "Default Aircraft"
        self.tableView.tableFooterView = UIView()
        self.aircraftRegTextField.delegate=self
        self.aircraftTypeTextField.delegate=self
        if let reg=defaults.string(forKey: "defaultAircraftRegistration"), let acType = defaults.string(forKey: "defaultAircraftType") {
            aircraftRegTextField.text = reg
            aircraftTypeTextField.text = acType
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
