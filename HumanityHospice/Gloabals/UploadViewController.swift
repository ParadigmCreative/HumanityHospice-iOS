//
//  UploadViewController.swift
//  HumanityHospice
//
//  Created by App Center on 7/2/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

//protocol UploadViewControllerDelegate {
//    func uploadView(updateCompletion percent: Float)
//    func startUpload()
//    func endUpload()
//}

class UploadViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 5
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
    }

    func startUpload() {
        self.activityIndicator.startAnimating()
        self.progressView.setProgress(0.01, animated: true)
    }
    
    func uploadView(updateCompletion percent: Float) {
        self.progressView.setProgress(percent, animated: true)
    }
    
    func endUpload() {
        hideProgess()
    }
    
    func hideProgess() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
