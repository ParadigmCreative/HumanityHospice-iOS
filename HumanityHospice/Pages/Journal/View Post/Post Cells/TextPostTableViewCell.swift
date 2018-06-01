//
//  TextPostTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class TextPostTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var post: Post! {
        didSet {
            if let urlString = post.posterProfileURL {
                if let url = URL(string: urlString) {
                    DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                        if error != nil {
                            print("Couldn't get Profile Image:", error!.localizedDescription)
                            self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
                        } else {
                            if let img = image {
                                try! RealmHandler.realm.write {
                                    self.post.posterProfilePicture = img.prepareImageForSaving()
                                    RealmHandler.realm.add(self.post, update: true)
                                }
                                DispatchQueue.main.async {
                                    self.profilePictureView.image = img
                                    self.profilePictureView.setupSecondaryProfilePicture()
                                }
                            }
                        }
                    }
                }
            } else {
                self.profilePictureView.image = #imageLiteral(resourceName: "Logo")
            }
        }
    }
    
    
    

}
