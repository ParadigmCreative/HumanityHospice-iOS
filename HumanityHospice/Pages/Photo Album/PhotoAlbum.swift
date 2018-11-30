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
        listenForImageDelete()
        
        if let type = AppSettings.userType {
            switch type {
            case .Reader, .Staff:
                self.addPhotoButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil 
            default:
                Log.d(type)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getImages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ownerDidRequestDeleteImage, object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var posts: [PhotoAlbumCollectionItem] = []
    
    func getImages() {
        RealmHandler.resetPhotoAlbum()
        DatabaseHandler.getImageDataFromDatabase {
            var journalPosts: [Post] = []
            var photoAlbumPosts: [PhotoAlbumPost] = []
            
            let photoAlbumImages = RealmHandler.getPhotoAlbumPosts()
            photoAlbumPosts.append(contentsOf: photoAlbumImages)
            
            let posts = RealmHandler.getPostList()
            if posts.count > 0 {
                let imagePosts = posts.filter { (p) -> Bool in
                    return p.hasImage == true
                }
                
                journalPosts.append(contentsOf: imagePosts)
            }
            
            let newposts = self.prepareImagesForCollection(journalPosts: journalPosts, PAPs: photoAlbumPosts)
            DispatchQueue.main.async {
                self.posts = newposts
                self.collectionView!.reloadData()
            }
        }
    }
    
    func prepareImagesForCollection(journalPosts: [Post], PAPs: [PhotoAlbumPost]) -> [PhotoAlbumCollectionItem] {
        
        var collectionPosts: [PhotoAlbumCollectionItem] = []
        
        for post in journalPosts {
            var newPost = PhotoAlbumCollectionItem()
            if let img = post.postImage?.getImageFromData() {
                newPost.image = img
            }
            newPost.caption = post.message
            newPost.timestamp = post.timestamp
            newPost.id = post.id
            newPost.url = post.imageURL
            
            collectionPosts.append(newPost)
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
            newPost.name = post.name
            
            collectionPosts.append(newPost)
        }
        
        let sorted = collectionPosts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
        
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
        cell.post = post
        
        cell.image.layer.cornerRadius = 5
        cell.image.clipsToBounds = true
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let realm = try! Realm()
        let key = posts[indexPath.row].id
        if let post = realm.object(ofType: PhotoAlbumPost.self, forPrimaryKey: key) {
            ImageViewer.currentlyViewingID = key
            ImageViewer.currentlyViewingIndex = indexPath.row
            post.viewImage(vc: self, isFromJournal: false)
        } else if let post = realm.object(ofType: Post.self, forPrimaryKey: key) {
            ImageViewer.currentlyViewingID = key
            ImageViewer.currentlyViewingIndex = indexPath.row
            post.viewImage(vc: self, isFromJournal: false)
        }
    }
    
    func listenForImageDelete() {
        NotificationCenter.default.addObserver(forName: .ownerDidRequestDeleteImage, object: nil, queue: .current) { (notification) in
            if let user = AppSettings.currentFBUser {
                if let result = RealmHandler.realm.objects(Post.self).filter({ (post) -> Bool in
                    if post.id == ImageViewer.currentlyViewingID && post.hasImage == true {
                        return true
                    } else {
                        return false
                    }
                }).first {
                    self.showJournalDeleteAlert(uid: user.uid, photoID: ImageViewer.currentlyViewingID, result: result)
                } else {
                    self.showDeleteAlert(uid: user.uid, photoID: ImageViewer.currentlyViewingID)
                }
            }
        }
    }
    
    func showDeleteAlert(uid: String, photoID: String) {
        let alert = UIAlertController(title: "Attention!", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let time = Int(self.posts[ImageViewer.currentlyViewingIndex].timestamp.rounded())
            let storagekey = self.posts[ImageViewer.currentlyViewingIndex].name
            DatabaseHandler.database.child("PhotoAlbum").child(uid).child(photoID).setValue(nil)
            DatabaseHandler.storage.child("PhotoAlbum").child(uid).child(storagekey).delete(completion: { (error) in
                if error != nil {
                    Log.e(error!.localizedDescription)
                } else {
                    alert.dismiss(animated: true, completion: nil)
                    ImageViewer.viewer.dismiss(animated: true, completion: nil)
                    self.posts.remove(at: ImageViewer.currentlyViewingIndex)
                    self.collectionView?.deleteItems(at: [IndexPath(row: ImageViewer.currentlyViewingIndex, section: 0)])
                    self.collectionView?.reloadData()
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showJournalDeleteAlert(uid: String, photoID: String, result: Post) {
        let alert = UIAlertController(title: "Attention!", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let time = Int(self.posts[ImageViewer.currentlyViewingIndex].timestamp.rounded())
            DatabaseHandler.database.child("Journals").child(AppSettings.currentPatient!).child(result.id).child("PostImageURL").setValue(nil)
            if let refString = self.posts[ImageViewer.currentlyViewingIndex].url {
                let ref = DatabaseHandler.storage.storage.reference(forURL: refString)
                ref.delete(completion: { (error) in
                    if error != nil {
                        Log.e(error!.localizedDescription)
                    } else {
                        alert.dismiss(animated: true, completion: nil)
                        self.posts.remove(at: ImageViewer.currentlyViewingIndex)
                        self.collectionView?.deleteItems(at: [IndexPath(row: ImageViewer.currentlyViewingIndex, section: 0)])
                        self.collectionView?.reloadData()
                    }
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Empty Data Set
    func setupEmptyDataSet() {
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "No photos yet!"
        let attStr = NSAttributedString(string: title)
        return attStr
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var desc = "Click the '+' button in the top right to add a new photo."
        if AppSettings.userType != .Patient || AppSettings.userType != .Family {
            desc = ""
        }
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
    var name: String = ""
    
    init() {
        self.image = nil
        self.caption = nil
        self.timestamp = 0.0
    }
}
