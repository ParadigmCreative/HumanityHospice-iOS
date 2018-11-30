//
//  PostWithImageTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: UITableViewCell {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var postPhoto: UIImageView!
    var commentDelegate: CommentsDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var indicator: UIActivityIndicatorView!
    
    var profilePicture: TableViewImage?
    var postImage: TableViewImage?
    
    var post: Post! {
        didSet {
            
            if let url = self.post.imageURL {
                self.postImage = TableViewImage()
                self.postImage?.imageURLString = url
                
                if let imgData = journalImageCache.object(forKey: NSString(string: url)) {
                    if let data = imgData as? Data {
                        if let img = data.getImageFromData() {
                            DispatchQueue.main.async {
                                self.postPhoto.image = img
                                self.postPhoto.contentMode = .scaleAspectFill
                                try! RealmHandler.realm.write {
                                    self.post.postImage = data
                                    RealmHandler.realm.add(self.post, update: true)
                                }
                                self.setupImageProperties()
                            }
                        }
                    }
                } else {
                    if let urlString = self.post.imageURL {
                        self.postImage?.imageURLString = url
                        if let url = URL(string: urlString) {
                            DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                                if error != nil {
                                    Log.e(error!.localizedDescription)
                                } else {
                                    if let img = image {
                                        let newimage = TableViewImage(cgImage: img.cgImage!)
                                        newimage.imageURLString = url.absoluteString
                                        // Cached downloaded post image
                                        if let data = newimage.prepareImageForSaving() {
                                            journalImageCache.setObject(NSData(data: data), forKey: NSString(string: urlString))
                                            try! RealmHandler.realm.write {
                                                self.post.postImage = data
                                                RealmHandler.realm.add(self.post, update: true)
                                            }
                                        }
                                        
                                        DispatchQueue.main.async {
                                            if urlString == self.postImage?.imageURLString {
                                                self.postPhoto.image = img
                                                self.postPhoto.contentMode = .scaleAspectFill
                                                self.setupImageProperties()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if let posterProfileURL = post.posterProfileURL {
                // setup
                setup(posterProfileURL: posterProfileURL)
            } else {
                // Check DB for profile picture
                DatabaseHandler.checkForProfilePicture(for: post.posterUID) { (url) in
                    if let url = url {
                        // Setup
                        try! RealmHandler.realm.write {
                            self.post.posterProfileURL = url
                            RealmHandler.realm.add(self.post, update: true)
                        }
                        self.setup(posterProfileURL: url)
                    } else {
                        // No Profile picture
                        DispatchQueue.main.async {
                            self.profilePictureImageView.image = #imageLiteral(resourceName: "Logo")
                        }
                    }
                }
            }
        }
    }
    
    func setup(posterProfileURL: String) {
        profilePicture = TableViewImage()
        profilePicture?.imageURLString = posterProfileURL
        
        if let imgData = profilePictureCache.object(forKey: NSString(string: posterProfileURL)) {
            let data = imgData as Data
            if let img = data.getImageFromData() {
                DispatchQueue.main.async {
                    self.profilePictureImageView.image = img
                    self.profilePictureImageView.setupSecondaryProfilePicture()
                    self.profilePictureImageView.contentMode = .scaleAspectFill
                }
            }
        } else {
            if let path = URL(string: posterProfileURL) {
                DatabaseHandler.getProfilePicture(URL: path, completion: { (image) in
                    if let img = image {
                        
                        if let data = img.prepareImageForSaving() {
                            profilePictureCache.setObject(NSData(data: data), forKey: NSString(string: posterProfileURL))
                        }
                        
                        DispatchQueue.main.async {
                            if posterProfileURL == self.profilePicture?.imageURLString {
                                self.profilePictureImageView.image = img
                                self.profilePictureImageView.setupSecondaryProfilePicture()
                                self.profilePictureImageView.contentMode = .scaleAspectFill
                            } else {
                                Log.e("URLs did not match on set")
                            }
                        }
                        
                        RealmHandler.write({ (realm) in
                            try! realm.write {
                                self.post.posterProfilePicture = img.prepareImageForSaving()
                                realm.add(self.post, update: true)
                            }
                        })
                        
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.profilePictureImageView.image = #imageLiteral(resourceName: "Logo")
                }
            }
        }
    }
    
    func setupUI() {
        if let url = post.imageURL {
            if let url = URL(string: url) {
                DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                    if error != nil {
                        Log.e(error!.localizedDescription)
                    } else {
                        // save image to realm in data form
                        if let data = image?.prepareImageForSaving() {
                            try! DatabaseHandler.realm.write {
                                self.post.postImage = data
                                DatabaseHandler.realm.add(self.post, update: true)
                            }
                        }
                        
                        // set image to imageView
                        DispatchQueue.main.async {
                            self.postPhoto.image = image
                            self.indicator.stopAnimating()
                            self.indicator.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }

    func setupImageProperties() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewImage))
        self.postPhoto.isUserInteractionEnabled = true
        self.postPhoto.addGestureRecognizer(tap)
    }
    
    @objc func viewImage() {
        if let vc = MenuHandler.staticMenu?.handlingController {
            self.post.viewImage(vc: vc, isFromJournal: true)
        }
    }
    
    @IBAction func showComments(_ sender: Any) {
        Log.d("Comments")
        commentDelegate.userDidSelectPostForComments(post: self.post)
    }



}


extension Data {
    func getImageFromData() -> TableViewImage? {
        if let img = TableViewImage(data: self) {
            return img
        } else {
            return nil
        }
    }
}

extension UIImage {
    func prepareImageForSaving() -> Data? {
        if let img = UIImagePNGRepresentation(self) {
            return img
        } else {
            return nil
        }
    }
}





