//
//  WayPointPhotoViewController.swift
//  WayPoints
//
//  Created by apple on 11/7/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointPhotoViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView?.contentSize = imageView.frame.size
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 3.0
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    private var imageView = UIImageView()
    
    var image : UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
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
