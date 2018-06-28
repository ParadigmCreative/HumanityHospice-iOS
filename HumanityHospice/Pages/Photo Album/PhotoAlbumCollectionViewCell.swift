//
//  PhotoAlbumCollectionViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/16/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    var realm = try! Realm()
    @IBOutlet weak var image: UIImageView!
    var indicator: UIActivityIndicatorView?
    
    var post: PhotoAlbumCollectionItem! {
        didSet {
            if post.image == nil {
                setupUI()
            } else {
                DispatchQueue.main.async {
                    if let img = self.post.image {
                        self.image.image = img
                    }
                }
            }
        }
    }
    
    func setupUI() {
        if let url = post.url {
            if let url = URL(string: url) {
                DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        // set image to imageView IMMEDIATELY
                        DispatchQueue.main.async {
                            self.image.image = image
                            self.image.layer.cornerRadius = 5
                        }
                        
                        // Do the admin work on the background
                        DispatchQueue.global(qos: .utility).async {
                            // save image to realm in data form
                            if let data = image?.prepareImageForSaving() {
                                RealmHandler.write({ (realm) in
                                    if let obj = realm.object(ofType: PhotoAlbumPost.self,
                                                              forPrimaryKey: self.post.id) {
                                        try! realm.write {
                                            obj.image = data
                                            self.realm.add(obj, update: true)
                                            print("Updated \(obj.id) 's img in realm")
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                print("Couldn't get image URL")
            }
        } else {
            print("Couldn't get image URL")
        }
    }
}
