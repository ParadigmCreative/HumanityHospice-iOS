//
//  ProfilePickerDelegate.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import ImagePicker

protocol ProfilePictureDelegate {
    func userDidSelectPhoto(image: UIImage)
}

class ProfilePickerDelegate: ImagePickerDelegate {
    
    var progressView: UIView?
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingIndicator = UIProgressView(progressViewStyle: .default)
    
    func setupProgress() {
        self.progressView = UIView()
        self.progressView?.backgroundColor = UIColor.darkGray
        self.progressView?.layer.cornerRadius = 5
        self.progressView?.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        
        self.progressView?.addSubview(activityIndicator)
        activityIndicator.center = progressView!.center
        self.progressView?.addSubview(loadingIndicator)
        let h = loadingIndicator.frame.height
        let w = progressView!.frame.width - 32
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: w, height: h)
        loadingIndicator.center = CGPoint(x: (progressView!.center.x), y: activityIndicator.center.y + 50)
        loadingIndicator.setProgress(0.01, animated: true)
    }
    
    
    // MARK: - ImagePickerDelegate
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("Wrapper")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let img = images.first {
//            Utilities.showActivityIndicator(view: imagePicker.view)
            activityIndicator.startAnimating()
            ProfilePickerHandler.chosenPhoto = img
            MenuHandler.staticMenu?.setupProfilePicture(img: img)
            DatabaseHandler.setProfilePicture { (done, error)  in
                if done {
                    self.activityIndicator.stopAnimating()
                    self.progressView?.removeFromSuperview()
                    print("Done setting profile image to storage")
                    imagePicker.dismiss(animated: true, completion: nil)
                } else {
                    print(error)
                    self.activityIndicator.stopAnimating()
                    self.progressView?.removeFromSuperview()
                    imagePicker.dismiss(animated: true, completion: nil)
                }
            }
            
            setupProgress()
            self.progressView?.center = imagePicker.view.center
            imagePicker.view.addSubview(progressView!)
            
            DatabaseHandler.manageProfilePictureUploadTask { (snap) in
                if let progress = snap.progress {
                    
                    let percent = progress.fractionCompleted
                    self.loadingIndicator.setProgress(Float(percent), animated: true)
                }
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
