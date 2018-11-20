//
//  ImageViewer.swift
//  HumanityHospice
//
//  Created by App Center on 5/7/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
//import Lightbox
import Serrata

class ImageViewer {
//    private static var viewer = LightboxController()
    public static var viewer = SlideLeafViewController()
    public static var viewerDelegate = ViewerDelegate()
    public static var isViewing: Bool = false
    public static var currentlyViewingID = ""
    public static var currentlyViewingIndex = 0
    
    public static func initialize(image: UIImage, text: String) {

        var title = "    "
        
        if let user = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            title = "Delete Photo"
            viewerDelegate.shouldDelete = true
        } else if let user = AppSettings.currentAppUser as? DatabaseHandler.Family {
            title = "Delete Photo"
            viewerDelegate.shouldDelete = true
        } else {
            title = "    "
            viewerDelegate.shouldDelete = false
        }
        
        let leaf = SlideLeaf(image: image, title: title, caption: text)
        viewer = SlideLeafViewController.make(leafs: [leaf])
        viewer.delegate = viewerDelegate
        
    }
    
    public static func reset() {
        viewer = SlideLeafViewController()
        isViewing = false
    }
    
    public static func open(vc: UIViewController) {
        vc.present(self.viewer, animated: true, completion: {
            self.isViewing = true
        })
    }
    
}


class ViewerDelegate: SlideLeafViewControllerDelegate {
    var shouldDelete: Bool = false
    
    func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int) {
        ImageViewer.reset()
    }
    
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        if shouldDelete {
            NotificationCenter.default.post(name: .ownerDidRequestDeleteImage, object: nil, userInfo: ["info": ImageViewer.currentlyViewingID])
        } else {
            // Do nothing
            print("Do nothing")
        }
    }
    
}

extension Post {
    func viewImage(vc: UIViewController) {
        if let data = self.postImage {
            if let image = data.getImageFromData() {
                ImageViewer.initialize(image: image, text: self.message)
                ImageViewer.open(vc: vc)
            }
        }
    }
}

extension PhotoAlbumPost {
    func viewImage(vc: UIViewController) {
        if let img = self.image?.getImageFromData() {
            if let text = self.caption {
                ImageViewer.initialize(image: img, text: text)
                ImageViewer.open(vc: vc)
            } else {
                ImageViewer.initialize(image: img, text: "    ")
                ImageViewer.open(vc: vc)
            }
        }
    }
}
