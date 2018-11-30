//
//  CommentTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageTF: UITextView!
    
    var post: Post! {
        didSet {
//            if let img = post.posterProfilePicture?.getImageFromData() {
//                DispatchQueue.main.async {
//                    self.profilePictureView.image = img
//                }
//            } else {
//                if let urlString = post.posterProfileURL {
//                    if let url = URL(string: urlString) {
//                        DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
//                            if error != nil {
//                                Log.e("Couldn't get Profile Image:", error!.localizedDescription)
//                                self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
//                            } else {
//                                if let img = image {
//                                    try! RealmHandler.realm.write {
//                                        self.post.posterProfilePicture = img.prepareImageForSaving()
//                                        RealmHandler.realm.add(self.post, update: true)
//                                    }
//                                    DispatchQueue.main.async {
//                                        self.profilePictureView.image = img
//                                        self.profilePictureView.setupSecondaryProfilePicture()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
//                    self.profilePictureView.setupSecondaryProfilePicture()
//                }
//            }
//        
            if let img = self.post.postImage?.getImageFromData() {
                DispatchQueue.main.async {
                    self.profilePictureView.image = img
                    self.profilePictureView.setupSecondaryProfilePicture()
                    self.profilePictureView.contentMode = .scaleAspectFill
                }
            } else {
                DatabaseHandler.checkForProfilePicture(for: self.post.posterUID) { (urlString) in
                    if let url = urlString {
                        if let path = URL(string: url) {
                            DatabaseHandler.getProfilePicture(URL: path, completion: { (image) in
                                if let img = image {
                                    DispatchQueue.main.async {
                                        self.profilePictureView.image = img
                                        self.profilePictureView.setupSecondaryProfilePicture()
                                        self.profilePictureView.contentMode = .scaleAspectFill
                                    }
                                    
                                    RealmHandler.write({ (realm) in
                                        try! realm.write {
                                            Log.d("1 - Starting Update")
                                            self.post.posterProfilePicture = img.prepareImageForSaving()
                                            realm.add(self.post, update: true)
                                            Log.d("2 - DONE UPDATING IMAGE")
                                        }
                                    })
                                }
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
                        }
                    }
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
