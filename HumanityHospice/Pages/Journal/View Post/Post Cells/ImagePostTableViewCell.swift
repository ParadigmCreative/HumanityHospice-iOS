//
//  ImagePostTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class ImagePostTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var post: Post! {
        didSet {

            // profile image
            if let posterProfileURL = self.post.posterProfileURL {
                setup(posterProfileURL: posterProfileURL)
            } else {
                DatabaseHandler.checkForProfilePicture(for: post.posterUID) { (url) in
                    if let url = url {
                        // Start Setup
                        try! RealmHandler.realm.write {
                            self.post.posterProfileURL = url
                            RealmHandler.realm.add(self.post, update: true)
                        }
                        self.setup(posterProfileURL: url)
                    } else {
                        // No Profile Picture
                        DispatchQueue.main.async {
                            self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
                        }
                    }
                }
            }
            
            if let url = self.post.imageURL {
                self.postImage = TableViewImage()
                self.postImage?.imageURLString = url
                
                if let imgData = journalImageCache.object(forKey: NSString(string: url)) {
                    if let data = imgData as? Data {
                        if let img = data.getImageFromData() {
                            DispatchQueue.main.async {
                                self.postImageView.image = img
                                self.postImageView.contentMode = .scaleAspectFill
                            }
                        }
                    }
                } else {
                    if let urlString = self.post.imageURL {
                        self.postImage?.imageURLString = url
                        if let url = URL(string: urlString) {
                            DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else {
                                    if let img = image {
                                        
                                        // Cached downloaded post image
                                        if let data = image?.prepareImageForSaving()  {
                                            journalImageCache.setObject(NSData(data: data), forKey: NSString(string: urlString))
                                        }
                                        
                                        DispatchQueue.main.async {
                                            if urlString == self.postImage?.imageURLString {
                                                self.postImageView.image = img
                                                self.postImageView.contentMode = .scaleAspectFill
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        setupImageProperties()
                    }
                }
            }
            
            
        }
    }
    
    
    var profilePicture: TableViewImage?
    var postImage: TableViewImage?
    
    func setup(posterProfileURL: String) {
        profilePicture = TableViewImage()
        profilePicture?.imageURLString = posterProfileURL
        
        if let imgData = profilePictureCache.object(forKey: NSString(string: posterProfileURL)) {
            let data = imgData as Data
            if let img = data.getImageFromData() {
                DispatchQueue.main.async {
                    self.profilePictureView.image = img
                    self.profilePictureView.setupSecondaryProfilePicture()
                    self.profilePictureView.contentMode = .scaleAspectFill
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
                                self.profilePictureView.image = img
                                self.profilePictureView.setupSecondaryProfilePicture()
                                self.profilePictureView.contentMode = .scaleAspectFill
                            } else {
                                print("URLs did not match on set")
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
                    self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
                }
            }
        }
    }
    
    func setupImageProperties() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewImage))
        self.postImageView.isUserInteractionEnabled = true
        self.postImageView.addGestureRecognizer(tap)
    }
    
    @objc func viewImage() {
        if let vc = MenuHandler.staticMenu?.handlingController {
            self.post.viewImage(vc: vc, isFromJournal: true)
        }
    }

}
