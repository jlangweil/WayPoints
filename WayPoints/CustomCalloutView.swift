

import UIKit

class CustomCalloutView: UIView {

    @IBOutlet weak var wayPointImage: UIImageView!
    @IBOutlet weak var wayPointUsername: UILabel!
    @IBOutlet weak var wayPointDescription: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var turbStatus: UILabel!
    @IBOutlet weak var icingStatus: UILabel!
    @IBOutlet weak var precipImage: UIImageView!
    @IBOutlet weak var skyStatus: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.wayPointDescription.setContentOffset(.zero, animated: false)
    }

}
