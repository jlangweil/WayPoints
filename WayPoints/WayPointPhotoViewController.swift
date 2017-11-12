//
//  WayPointPhotoViewController.swift
//  WayPoints
//
//  Created by apple on 11/7/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit

class WayPointPhotoViewController: UIViewController, UIScrollViewDelegate {

    var frameHeight : CGFloat?
    var frameWidth : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.black
        scrollView?.contentSize = imageView.frame.size
        // Do any additional setup after loading the view.
        frameHeight = self.view.frame.size.height
        let heightOfBars = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height + self.tabBarController!.tabBar.frame.height
        frameWidth = self.view.frame.size.width
        let imageHeight = imageView.image!.size.height
        let imageWidth = imageView.image!.size.width
        var minZoom = min(frameWidth! / imageWidth, frameHeight! / imageHeight)
        
        if (minZoom > 1.0) {
            minZoom = 1.0;
        }
        
        self.scrollView.minimumZoomScale = minZoom;
        self.scrollView.zoomScale = minZoom;
        
        imageView.center = CGPoint(x:frameWidth!/2, y:(frameHeight!-heightOfBars)/2)
        
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            //scrollView.minimumZoomScale = 0.1
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenter()
    }
    
    
    func recenter() {
        let subView = scrollView.subviews[0] // get the image view
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        // adjust the center of image view
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y:scrollView.contentSize.height * 0.5 + offsetY)
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
