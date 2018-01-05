//
//  WayPointCustomTableCell.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointCustomTableCell: UITableViewCell {

    
    @IBOutlet weak var wayPointImageView: UIImageView!
    @IBOutlet weak var wayPointTitleLabel: UILabel!
    @IBOutlet weak var wayPointDescriptionLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var aircraftLabel: UILabel!
    @IBOutlet weak var aircraftTypeLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var citystate: UILabel!
    
    
    var imageID : String?
    

}
