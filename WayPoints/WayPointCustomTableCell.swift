//
//  WayPointCustomTableCell.swift
//  WayPoints
//
//  Created by apple on 11/5/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointCustomTableCell: UITableViewCell {

    
    @IBOutlet weak var wayPointTitleLabel: UILabel!
    
    var wayPointTableData: String? { didSet {updateUI() } }
    
    private func updateUI() {
        wayPointTitleLabel?.text = wayPointTableData // replace with bigger structure for the whole cell once designed
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
