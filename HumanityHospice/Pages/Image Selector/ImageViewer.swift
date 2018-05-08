//
//  ImageViewer.swift
//  HumanityHospice
//
//  Created by App Center on 5/7/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import Lightbox

class ImageViewer {
    private static var viewer = LightboxController()
    private static var viewerDelegate = ViewerDelegate()
    public static var isViewing: Bool = false
    
    public static func initialize(image: UIImage, text: String) {
        let img = LightboxImage(image: image, text: text, videoURL: nil)
        
        viewer = LightboxController(images: [img], startIndex: 0)
        viewer.pageDelegate = viewerDelegate
        viewer.dismissalDelegate = viewerDelegate
        
        viewer.dynamicBackground = true
        
    }
    
    public static func reset() {
        viewer = LightboxController()
        isViewing = false
    }
    
    public static func open(vc: UIViewController) {
        vc.present(self.viewer, animated: true, completion: {
            self.isViewing = true
        })
    }
    
}


class ViewerDelegate: LightboxControllerPageDelegate, LightboxControllerDismissalDelegate {
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print("Page:", page)
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        ImageViewer.reset()
    }
    
    
}

extension Post {
    func viewImage(vc: UIViewController) {
        if let image = self.postImage {
            ImageViewer.initialize(image: image, text: self.message)
            ImageViewer.open(vc: vc)
        }
    }
}
