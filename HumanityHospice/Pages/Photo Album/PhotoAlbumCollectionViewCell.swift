//
//  PhotoAlbumCollectionViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/16/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import RealmSwift

var photoAlbumImageCache = NSCache<NSString, NSData>()

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    var realm = try! Realm()
    @IBOutlet weak var image: UIImageView!
    var indicator: UIActivityIndicatorView?
    
    var postImage: TableViewImage?
    
    var post: PhotoAlbumCollectionItem! {
        didSet {
            
            if let photoURL = post.url {
                self.postImage = TableViewImage()
                self.postImage?.imageURLString = photoURL
                
                // Checks to see if the image exists in journal cache
                if let data = journalImageCache.object(forKey: NSString(string: photoURL)) {
                    
                    let imgData = data as Data
                    if let img = imgData.getImageFromData() {
                        DispatchQueue.main.async {
                            self.image.image = img
                            self.image.layer.cornerRadius = 5
                        }
                    } else {
                        Log.e("Could not parse image from Data")
                        // Set default
                    }
                    
                // Checks to see if the image exists in the photo album cache
                } else if let data = photoAlbumImageCache.object(forKey: NSString(string: photoURL)) {
                    
                    let imgData = data as Data
                    if let img = imgData.getImageFromData() {
                        DispatchQueue.main.async {
                            self.image.image = img
                            self.image.layer.cornerRadius = 5
                        }
                    } else {
                        Log.e("Could not parse image from Data")
                        // Set default
                    }
                    
                // Image does not exist in either cache, go try to get it
                } else {
                    if let url = URL(string: photoURL) {
                        DatabaseHandler.getImageFromStorage(url: url) { (image, error) in
                            if error != nil {
                                Log.e(error!.localizedDescription)
                            } else {
                                
                                if let data = image!.prepareImageForSaving() {
                                    photoAlbumImageCache.setObject(NSData(data: data), forKey: NSString(string: photoURL))
                                }
                                
                                DispatchQueue.main.async {
                                    if self.postImage?.imageURLString == photoURL {
                                        self.image.image = image
                                        self.image.layer.cornerRadius = 5
                                    }
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
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // This should throw an error becuase all photos should have a URL
                Log.e("Photo did not have a URL")
            }
        }
    }
}
