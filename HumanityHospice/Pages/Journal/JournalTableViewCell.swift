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
            // profile image
            if let img = self.post.postImage?.getImageFromData() {
                DispatchQueue.main.async {
                    self.userImage.image = img
                    self.userImage.setupSecondaryProfilePicture()
                    self.userImage.contentMode = .scaleAspectFill
                }
            } else {
                DatabaseHandler.checkForProfilePicture(for: self.post.posterUID) { (urlString) in
                    if let url = urlString {
                        if let path = URL(string: url) {
                            DatabaseHandler.getProfilePicture(URL: path, completion: { (image) in
                                if let img = image {
                                    DispatchQueue.main.async {
                                        self.userImage.image = img
                                        self.userImage.setupSecondaryProfilePicture()
                                        self.userImage.contentMode = .scaleAspectFill
                                    }
                                    
                                    RealmHandler.write({ (realm) in
                                        try! realm.write {
                                            self.post.posterProfilePicture = img.prepareImageForSaving()
                                            realm.add(self.post, update: true)
                                        }
                                    })
                                }
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.userImage.image = #imageLiteral(resourceName: "Logo")
                        }
                    }
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
