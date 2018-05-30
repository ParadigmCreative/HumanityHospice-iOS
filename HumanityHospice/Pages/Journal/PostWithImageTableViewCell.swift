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
                        
                        self.post.postImage = image?.prepareImageForSaving()
                        
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





