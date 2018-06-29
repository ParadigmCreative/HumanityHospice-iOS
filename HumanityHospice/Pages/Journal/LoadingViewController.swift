//
//  LoadingViewController.swift
//  HumanityHospice
//
//  Created by App Center on 6/2/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, LoadingViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var indicator: UIActivityIndicatorView!
    
    func setup() {
        self.view.backgroundColor = #colorLiteral(red: 0.5378926079, green: 0.5378926079, blue: 0.5378926079, alpha: 0.5494434932)
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.color = #colorLiteral(red: 0.4588235294, green: 0.4470588235, blue: 0.7568627451, alpha: 1)
        indicator.center = self.view.center
        indicator.startAnimating()
        self.view.addSubview(indicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func complete() {
        UIApplication.shared.endIgnoringInteractionEvents()
        if indicator != nil {
            indicator.stopAnimating()
        }
        self.dismiss(animated: true, completion: nil)
    }

}

protocol LoadingViewDelegate {
    func complete()
}

