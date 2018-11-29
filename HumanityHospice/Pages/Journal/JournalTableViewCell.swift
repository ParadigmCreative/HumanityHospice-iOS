//
//  JournalTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

let journalImageCache = NSCache<NSString, NSData>()
let profilePictureCache = NSCache<NSString, NSData>()

class JournalTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var profilePicture: TableViewImage?
    
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
                            self.userImage.image = #imageLiteral(resourceName: "Logo")
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
                    self.userImage.image = img
                    self.userImage.setupSecondaryProfilePicture()
                    self.userImage.contentMode = .scaleAspectFill
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
                                self.userImage.image = img
                                self.userImage.setupSecondaryProfilePicture()
                                self.userImage.contentMode = .scaleAspectFill
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
                    self.userImage.image = #imageLiteral(resourceName: "Logo")
                }
            }
        }
    }
    
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var commentsButton: UIButton!
    var commentDelegate: CommentsDelegate!
    
    @IBAction func showComments(_ sender: Any) {
        print("Comments")
        commentDelegate.userDidSelectPostForComments(post: self.post)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol CommentsDelegate {
    func userDidSelectPostForComments(post: Post)
}
