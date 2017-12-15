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
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var aircraftLabel: UILabel!
    @IBOutlet weak var aircraftTypeLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    
    var imageID : String?
    
   /* internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                wayPointImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                wayPointImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    internal var heightConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                wayPointImageView.removeConstraint(oldValue!)
            }
            if heightConstraint != nil {
                wayPointImageView.addConstraint(heightConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
        //heightConstraint = nil
    }
    
    public func setCustomImage(image : UIImage?) {
        
        if image != nil {
            let aspect = image!.size.width / image!.size.height
            let constraint = NSLayoutConstraint(item: wayPointImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: wayPointImageView, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
            constraint.priority = .init(999)
            aspectConstraint = constraint
            wayPointImageView.image = image!
        }
        
    }*/
    
    var wayPointTableData: WayPointCustomTableCellData? { didSet {updateUI() } }
    
    private func updateUI() {
        wayPointDescriptionLabel.text = wayPointTableData?.description
        wayPointImageView.image = wayPointTableData?.image
        wayPointTimeLabel.text = wayPointTableData?.time
        wayPointTitleLabel.text = wayPointTableData?.location
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
  
    


}
