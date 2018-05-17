//
//  PhotoAlbum.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class PhotoAlbum: UICollectionViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        MenuHandler.staticMenu?.setHandingController(vc: self)
        setupEmptyDataSet()
        
        // Do any additional setup after loading the view.
        
        getImages { (posts) in
            self.posts = posts
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var posts: [Post] = []
    
    func getImages(completion: ([Post])->()) {
        let posts = RealmHandler.getPostList()
        if posts.count > 0 {
            let imagePosts = posts.filter { (p) -> Bool in
                return p.hasImage
            }
            
            completion(imagePosts)
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        MenuHandler.openMenu(vc: self)
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoAlbumCollectionViewCell
    
        // Configure the cell
        if let data = posts[indexPath.row].postImage {
            if let img = data.getImageFromData() {
                cell.image.image = img
            }
        }
        
        cell.image.layer.cornerRadius = 5
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        post.viewImage(vc: self)
        
    }
    
    
    
    // MARK: - Empty Data Set
    func setupEmptyDataSet() {
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "No posts yet!"
        let attStr = NSAttributedString(string: title)
        return attStr
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let desc = "Share your invite code to allow people to post in your Encouragement Board!"
        let attr = NSAttributedString(string: desc)
        return attr
    }
    

}
