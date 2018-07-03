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
    
    var post: Post! {
        didSet {
            
            // Post Image
            if let img = self.post.postImage?.getImageFromData() {
                DispatchQueue.main.async {
                    self.postPhoto.image = img
                    self.postPhoto.contentMode = .scaleAspectFill
                }
            } else {
                if let urlString = self.post.imageURL {
                    if let url = URL(string: urlString) {
                        DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                            if error != nil {
                               print(error!.localizedDescription)
                            } else {
                                if let img = image {
                                    DispatchQueue.main.async {
                                        self.postPhoto.image = img
                                        self.postPhoto.contentMode = .scaleAspectFill
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if let img = self.post.posterProfilePicture?.getImageFromData() {
                DispatchQueue.main.async {
                    self.profilePictureImageView.image = img
                    self.profilePictureImageView.setupSecondaryProfilePicture()
                    self.profilePictureImageView.contentMode = .scaleAspectFill
                }
            } else {
                DatabaseHandler.checkForProfilePicture(for: self.post.posterUID) { (urlString) in
                    if let url = urlString {
                        if let path = URL(string: url) {
                            DatabaseHandler.getProfilePicture(URL: path, completion: { (image) in
                                if let img = image {
                                    DispatchQueue.main.async {
                                        self.profilePictureImageView.image = img
                                        self.profilePictureImageView.setupSecondaryProfilePicture()
                                        self.profilePictureImageView.contentMode = .scaleAspectFill
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
                            self.profilePictureImageView.image = #imageLiteral(resourceName: "Logo")
                        }
                    }
                }
            }
            
            if post.postImage == nil {
                setupUI()
                setupImageProperties()
            } else {
                DispatchQueue.main.async {
                    if let img = self.post.postImage?.getImageFromData() {
                        self.postPhoto.image = img
                        self.setupImageProperties()
                        self.indicator.stopAnimating()
                        self.indicator.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func setupUI() {
        if let url = post.imageURL {
            if let url = URL(string: url) {
                DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                    if error != nil {
                        print(error!.localizedDescription)
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
            self.post.viewImage(vc: vc)
        }
    }
    
    @IBAction func showComments(_ sender: Any) {
        print("Comments")
        commentDelegate.userDidSelectPostForComments(post: self.post)
    }



}


extension Data {
    func getImageFromData() -> UIImage? {
        if let img = UIImage(data: self) {
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





