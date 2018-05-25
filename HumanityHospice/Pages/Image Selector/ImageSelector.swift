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
    private static var picker = ImagePickerController()
    private static var pickerDelegate = PickerDelegate()
    static var delegate: ImageSelectorDelegate?
    
    static var selectedImage: UIImage?
    
    static func open(vc: UIViewController) {
        setup()
        vc.present(picker, animated: true, completion: nil)
    }
    
    static func close() {
        selectedImage = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    private static func setup() {
        
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        configuration.allowPinchToZoom = true
        configuration.allowMultiplePhotoSelection = false
        
        self.picker = ImagePickerController(configuration: configuration)
        picker.delegate = pickerDelegate
        picker.imageLimit = 1
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







