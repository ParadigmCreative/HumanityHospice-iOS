//
//  PhotoAlbum.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RealmSwift

class PhotoAlbum: UICollectionViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        RealmHandler.resetPhotoAlbum()
        MenuHandler.staticMenu?.setHandingController(vc: self)
        setupEmptyDataSet()
        
        getImages()
        
        if let type = AppSettings.userType {
            switch type {
            case .Reader, .Staff:
                self.addPhotoButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil 
            default:
                print(type)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var posts: [PhotoAlbumCollectionItem] = []
    
    func prepareImagesForCollection(posts: [Post], PAPs: [PhotoAlbumPost]) -> [PhotoAlbumCollectionItem] {
        
        var imageposts: [PhotoAlbumCollectionItem] = []
        
        for post in posts {
            if let img = post.postImage!.getImageFromData() {
                var newPost = PhotoAlbumCollectionItem()
                newPost.caption = post.message
                newPost.image = img
                newPost.timestamp = post.timestamp
                newPost.id = post.id
                
                imageposts.append(newPost)
            }
        }
        
        for post in PAPs {
            var newPost = PhotoAlbumCollectionItem()
            
            if let img = post.image?.getImageFromData() {
                newPost.image = img
            }
            newPost.caption = post.caption
            newPost.timestamp = post.timestamp
            newPost.url = post.url
            newPost.id = post.id
            
            imageposts.append(newPost)
        }
        
        let sorted = imageposts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
        
    }
    
    func getImages() {
        RealmHandler.resetPhotoAlbum()
        DatabaseHandler.getImagesFromStorage {
            
            var journalPosts: [Post] = []
            var photoAlbumPosts: [PhotoAlbumPost] = []
            
            let photoAlbumImages = RealmHandler.getPhotoAlbumPosts()
            photoAlbumPosts.append(contentsOf: photoAlbumImages)
            
            let posts = RealmHandler.getPostList()
            if posts.count > 0 {
                let imagePosts = posts.filter { (p) -> Bool in
                    return p.hasImage
                }
                
                journalPosts.append(contentsOf: imagePosts)
            }
            
            let newposts = self.prepareImagesForCollection(posts: journalPosts, PAPs: photoAlbumPosts)
            DispatchQueue.main.async {
                self.posts = newposts
                self.collectionView!.reloadData()
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
    
        let post = posts[indexPath.row]
        
        let indicator = Utilities.createActivityIndicator(view: cell)
        cell.indicator = indicator
        cell.post = post
        
        // Configure the cell
        cell.image.image = post.image
        cell.image.layer.cornerRadius = 5
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let realm = try! Realm()
        let key = posts[indexPath.row].id
        if let post = realm.object(ofType: PhotoAlbumPost.self, forPrimaryKey: key) {
            post.viewImage(vc: self)
        } else if let post = realm.object(ofType: Post.self, forPrimaryKey: key) {
            post.viewImage(vc: self)
        }
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


struct PhotoAlbumCollectionItem {
    var image: UIImage?
    var caption: String?
    var timestamp: TimeInterval
    var url: String? = nil
    var id: String = ""
    
    init() {
        self.image = nil
        self.caption = nil
        self.timestamp = 0.0
    }
}
