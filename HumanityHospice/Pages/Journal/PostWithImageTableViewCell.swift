//
//  PostWithImageTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: JournalTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var postPhoto: UIImageView!
    var indicator: UIActivityIndicatorView!
    
    override var post: Post! {
        didSet {
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





