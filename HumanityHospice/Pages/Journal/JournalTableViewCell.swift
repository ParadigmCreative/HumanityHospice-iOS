//
//  JournalTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var post: Post! {
        didSet {
            
            // check user type
//            var userIDToGetProfilePicURLFrom: String = ""
//            
//            switch AppSettings.userType! {
//            case .Patient:
//                userIDToGetProfilePicURLFrom = AppSettings.currentPatient!
//            case .Family:
//                userIDToGetProfilePicURLFrom = AppSettings.currentPatient
//            case .Reader:
//                
//            case .Staff:
//                
//            }
            
            if let img = post.posterProfilePicture?.getImageFromData() {
                DispatchQueue.main.async {
                    self.userImage.image = img
                    self.userImage.setupSecondaryProfilePicture()
                    self.userImage.contentMode = .scaleAspectFill
                }
            } else {
                if let picURL = post.posterProfileURL {
                    if let url = URL(string: picURL) {
                        DatabaseHandler.getImageFromStorage(url: url) { (pic, error) in
                            if error != nil {
                                print("Can't get profile picture from storage")
                                self.userImage.image = #imageLiteral(resourceName: "Logo")
                            } else {
                                if let img = pic {
                                    DispatchQueue.main.async {
                                        self.userImage.image = img
                                        self.userImage.setupSecondaryProfilePicture()
                                    }
                                    try! RealmHandler.realm.write {
                                        self.post.posterProfilePicture = img.prepareImageForSaving()
                                        RealmHandler.realm.add(self.post, update: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
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
