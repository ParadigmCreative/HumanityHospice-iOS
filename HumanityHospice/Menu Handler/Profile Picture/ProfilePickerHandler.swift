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
    static var profilePictureDelegate: ProfilePictureDelegate?
    static var chosenPhoto: UIImage? {
        didSet {
            if chosenPhoto != nil {
                profilePictureDelegate?.userDidSelectPhoto(image: chosenPhoto!)
            }
        }
    }
    
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

extension ProfilePickerHandler: ProfilePictureDelegate {
    func userDidSelectPhoto(image: UIImage) {
        ProfilePickerHandler.chosenPhoto = image
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
    
    func setupSecondaryProfilePicture() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        let color = #colorLiteral(red: 0.2784313725, green: 0.1803921569, blue: 0.5490196078, alpha: 1)
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
