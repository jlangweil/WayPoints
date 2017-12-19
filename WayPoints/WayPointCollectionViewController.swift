//
//  WayPointCollectionViewController.swift
//  WayPoints
//
//  Created by apple on 12/17/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "waypointcell"

class WayPointCollectionViewController: UICollectionViewController {
    
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photos.removeAll()
        getAllData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllData() {
        let ref = Database.database().reference()
        ref.removeAllObservers()
        ref.child("waypoints").observeSingleEvent(of: .value, with: { [weak self](snapshot) in
            let dict = snapshot.value as? NSDictionary
            if dict != nil {
                for (key,value) in dict! {
                    let id = key as? String ?? ""
                    var aspect: String = ""
                    var timestamp: Int64 = 0
                    if let values = value as? NSDictionary {
                        aspect = values["imageAspect"] as? String ?? "0"
                        timestamp = values["timestamp"] as? Int64 ?? 0
                    }
                    if aspect != "0" {
                        let currentPhoto = Photo(id: id, aspect: aspect, timestamp: timestamp)
                        self?.photos.insert(currentPhoto, at: 0)
                        self?.photos.sort(by: {$0.timestamp > $1.timestamp})
                        self?.collectionView?.reloadData()
                    }
                }
            }
            
           
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WayPointCollectionViewCell
        
        // Configure the cell
        let currentPhoto = photos[indexPath.row]
        let id = currentPhoto.id
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let reference = storageRef.child("images/\(id)_thumb.jpg")
        let placeholder = UIImage(named: "placeholder")
        cell.imageView.sd_setImage(with: reference, placeholderImage: placeholder)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

struct Photo {
    var id: String
    var aspect: String
    var timestamp: Int64
}
