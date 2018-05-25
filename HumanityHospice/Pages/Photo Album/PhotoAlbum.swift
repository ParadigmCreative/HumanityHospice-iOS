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
        
        getImages { (posts, images) in
            let newposts = self.prepareImagesForCollection(posts: posts, PAPs: images)
            DispatchQueue.main.async {
                self.posts = newposts
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var posts: [PhotoAlbumPhotoObject] = []
    
    func prepareImagesForCollection(posts: [Post], PAPs: [PhotoAlbumPost]) -> [PhotoAlbumPhotoObject] {
        
        var imageposts: [PhotoAlbumPhotoObject] = []
        
        for post in posts {
            if let img = post.postImage!.getImageFromData() {
                var newPost = PhotoAlbumPhotoObject()
                newPost.caption = post.message
                newPost.image = img
                newPost.timestamp = post.timestamp
                
                imageposts.append(newPost)
            }
        }
        
        for post in PAPs {
            if let img = post.image?.getImageFromData() {
                var newPost = PhotoAlbumPhotoObject()
                newPost.caption = post.caption
                newPost.image = img
                newPost.timestamp = post.timestamp
                
                imageposts.append(newPost)
            }
        }
        
        let sorted = imageposts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
        
    }
    
    func getImages(completion: @escaping ([Post], [PhotoAlbumPost])->()) {
        
        DatabaseHandler.getImagesFromStorage { (done) in
            
            var jposts: [Post] = []
            var images: [PhotoAlbumPost] = []
            
            if done {
                let pimages = RealmHandler.getPhotoAlbumPosts()
                images.append(contentsOf: pimages)
                
                let posts = RealmHandler.getPostList()
                if posts.count > 0 {
                    let imagePosts = posts.filter { (p) -> Bool in
                        return p.hasImage
                    }
                    
                    jposts.append(contentsOf: imagePosts)
                }
                
                completion(jposts, images)
            } else {
                let pimages = RealmHandler.getPhotoAlbumPosts()
                images.append(contentsOf: pimages)
                
                let posts = RealmHandler.getPostList()
                if posts.count > 0 {
                    let imagePosts = posts.filter { (p) -> Bool in
                        return p.hasImage
                    }
                    
                    jposts.append(contentsOf: imagePosts)
                }
                
                completion(jposts, images)
            }
        }
        
    }
    
    @IBAction func showMenu(_ sender: Any) {
        MenuHandler.openMenu(vc: self)
    }
    
    // MARK: - Add New Photo
    @IBOutlet weak var addPhotoButton: UIBarButtonItem!
    @IBAction func addPhoto(_ sender: Any) {
        self.performSegue(withIdentifier: "addNewPhoto", sender: self)
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
        cell.image.image = posts[indexPath.row].image
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


struct PhotoAlbumPhotoObject {
    var image: UIImage?
    var caption: String?
    var timestamp: TimeInterval
    
    init() {
        self.image = nil
        self.caption = nil
        self.timestamp = 0.0
    }
}
