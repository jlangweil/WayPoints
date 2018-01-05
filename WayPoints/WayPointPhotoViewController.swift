//
//  WayPointPhotoViewController.swift
//  WayPoints
//
//  Created by apple on 11/7/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import Firebase

class WayPointPhotoViewController: UIViewController, UIScrollViewDelegate {

    var frameHeight : CGFloat?
    var frameWidth : CGFloat?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.black
        setUpViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let newWidth = size.width
        let newHeight = size.height
        var heightOfBars = CGFloat(171)
        var widthOfBars = CGFloat(88)
        if newWidth > newHeight {
            // landscape
            self.tabBarController!.tabBar.isHidden = true
            self.navigationController!.navigationBar.isHidden = true
            heightOfBars = CGFloat(0)  
        }
        else {
            self.tabBarController!.tabBar.isHidden = false
            self.navigationController!.navigationBar.isHidden = false
            widthOfBars = CGFloat(0)
        }
        
        imageView.center = CGPoint(x:newWidth/2, y:(newHeight-heightOfBars)/2)
        let imageHeight = imageView.image!.size.height
        let imageWidth = imageView.image!.size.width
        var minZoom = min(newWidth / imageWidth, newHeight / imageHeight)
        
        if (minZoom > 1.0) {
            minZoom = 1.0;
        }
        
        self.scrollView.minimumZoomScale = minZoom;
        self.scrollView.zoomScale = minZoom;
       
        imageView.center = CGPoint(x:(newWidth-widthOfBars)/2, y:(newHeight-heightOfBars)/2)
        imageView.sizeToFit()
    }
    
    private func setUpViews() {
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
        print("heightofbars: \(heightOfBars)")
        imageView.center = CGPoint(x:frameWidth!/2, y:(frameHeight!-heightOfBars)/2)
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
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
    
    
    private func recenter() {
        let subView = scrollView.subviews[0] // get the image view
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        // adjust the center of image view
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y:scrollView.contentSize.height * 0.5 + offsetY)
    }

}
