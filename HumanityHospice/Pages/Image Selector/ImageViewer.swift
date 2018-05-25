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
    private static var viewer = SlideLeafViewController()
    private static var viewerDelegate = ViewerDelegate()
    public static var isViewing: Bool = false
    
    public static func initialize(image: UIImage, text: String) {

        let leaf = SlideLeaf(image: image, title: "", caption: text)
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
    
    func slideLeafViewControllerDismissed(slideLeaf: SlideLeaf, pageIndex: Int) {
        ImageViewer.reset()
    }
    
    func tapImageDetailView(slideLeaf: SlideLeaf, pageIndex: Int) {
        
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

extension PhotoAlbumPhotoObject {
    func viewImage(vc: UIViewController) {
        if let img = self.image {
            if let text = self.caption {
                ImageViewer.initialize(image: img, text: text)
                ImageViewer.open(vc: vc)
            } else {
                ImageViewer.initialize(image: img, text: "")
                ImageViewer.open(vc: vc)
            }
        }
    }
}
