//
//  ImageSelector.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import ImagePicker

class ImageSelector {
    static var picker = ImagePickerController()
    static var pickerDelegate = PickerDelegate()
    static var delegate: ImageSelectorDelegate?
    
    static var selectedImage: UIImage?
    
    static func open(vc: UIViewController) {
        setup()
        picker.delegate = pickerDelegate
        vc.present(picker, animated: true, completion: nil)
    }
    
    static func close() {
        selectedImage = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    private static func setup() {
        picker.imageLimit = 1
    }
    
    static func open(with vc: UIViewController, delegate: ImagePickerDelegate) {
        setup()
        picker.delegate = delegate
        vc.present(picker, animated: true, completion: nil)
    }
    
}

class PickerDelegate: ImagePickerDelegate {
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let img = images.first {
            ImageSelector.selectedImage = img
            ImageSelector.delegate?.userDidSelectImage(image: img)
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
}


protocol ImageSelectorDelegate {
    func userDidSelectImage(image: UIImage)
}







