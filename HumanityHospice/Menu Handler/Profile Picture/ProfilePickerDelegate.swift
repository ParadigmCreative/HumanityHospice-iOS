//
//  ProfilePickerDelegate.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import ImagePicker

class ProfilePickerDelegate: ImagePickerDelegate {
    // MARK: - ImagePickerDelegate
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("Wrapper")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let img = images.first {
            ProfilePickerHandler.chosenPhoto = img
            MenuHandler.staticMenu?.setupProfilePicture(img: img)
            DatabaseHandler.setProfilePicture { (done) in
                if done {
                    print("Done setting profile image to storage")
                }
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
