//
//  ProfilePickerHandler.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import ImagePicker

class ProfilePickerHandler {
    static var pickerDelegate = ProfilePickerDelegate()
    static var picker: ImagePickerController?
    static var chosenPhoto: UIImage?
    
    static func setup() {
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        configuration.allowPinchToZoom = true
        configuration.allowMultiplePhotoSelection = false
        
        self.picker = ImagePickerController(configuration: configuration)
        picker?.delegate = self.pickerDelegate
        picker?.imageLimit = 1
    }
    
    static func open(vc: UIViewController) {
        setup()
        vc.present(picker!, animated: true, completion: nil)
    }
    
    static func close() {
        picker!.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIImageView {
    func setupProfilePicture() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
