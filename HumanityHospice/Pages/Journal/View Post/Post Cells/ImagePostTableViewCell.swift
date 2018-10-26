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
//            if let img = self.post.postImage?.getImageFromData() {
//                DispatchQueue.main.async {
//                    self.profilePictureView.image = img
//                    self.profilePictureView.setupSecondaryProfilePicture()
//                    self.profilePictureView.contentMode = .scaleAspectFill
//                }
//            } else {
//
//            }
            
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
                                        print("1 - Starting Update")
                                        self.post.posterProfilePicture = img.prepareImageForSaving()
                                        realm.add(self.post, update: true)
                                        print("2 - DONE UPDATING IMAGE")
                                    }
                                })
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
                        self.profilePictureView.setupSecondaryProfilePicture()
                        self.profilePictureView.contentMode = .scaleAspectFill
                    }
                }
            }
            
        }
    }
    
    
    
    
    

}
