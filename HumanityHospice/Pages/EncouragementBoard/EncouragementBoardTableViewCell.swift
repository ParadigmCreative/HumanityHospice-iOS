//
//  EncouragementBoardTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/9/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

let encBoardCache = NSCache<NSString, NSData>()

class EncouragementBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageTF: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var post: EBPost! {
        didSet {
            DatabaseHandler.getProfilePicture(for: post.posterUID) { (img) in
                if let image = img {
                    self.profilePicture.image = image
                    self.profilePicture.setupSecondaryProfilePicture()
                    self.profilePicture.contentMode = .scaleAspectFill
                } else {
                    self.profilePicture.image = #imageLiteral(resourceName: "Logo")
                }
            }
            
            if let profileURL = post.posterProfileURL {
                // Setup
                
            } else {
                DatabaseHandler.checkForProfilePicture(for: self.post.posterUID) { (url) in
                    if let url = url {
                        // Setup
                    } else {
                        self.profilePicture.image = #imageLiteral(resourceName: "Logo")
                    }
                }
            }
            
        }
    }
    
    var profilePictureObj: TableViewImage?
    
    func setup(posterProfileURL: String) {
        profilePictureObj = TableViewImage()
        profilePictureObj?.imageURLString = posterProfileURL
        
        if let imgData = profilePictureCache.object(forKey: NSString(string: posterProfileURL)) {
            let data = imgData as Data
            if let img = data.getImageFromData() {
                DispatchQueue.main.async {
                    self.profilePicture.image = img
                    self.profilePicture.setupSecondaryProfilePicture()
                    self.profilePicture.contentMode = .scaleAspectFill
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
                            if posterProfileURL == self.profilePictureObj?.imageURLString {
                                self.profilePicture.image = img
                                self.profilePicture.setupSecondaryProfilePicture()
                                self.profilePicture.contentMode = .scaleAspectFill
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
                    self.profilePicture.image = #imageLiteral(resourceName: "Logo")
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
