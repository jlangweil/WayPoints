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
    @IBOutlet weak var wayPointTimeLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var wayPointTableData: WayPointCustomTableCellData? { didSet {updateUI() } }
    
    private func updateUI() {
        wayPointDescriptionLabel.text = wayPointTableData?.description
        wayPointImageView.image = wayPointTableData?.image
        wayPointTimeLabel.text = wayPointTableData?.time
        wayPointTitleLabel.text = wayPointTableData?.user
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
