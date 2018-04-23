//
//  Utilities.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    private static var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    public static func showActivityIndicator(view: UIView) {
        self.indicator.color = #colorLiteral(red: 0.4605029225, green: 0.447249949, blue: 0.7566576004, alpha: 1)
        self.indicator.center = view.center
        self.indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        self.indicator.startAnimating()
    }
    
    public static func closeActivityIndicator() {
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
}




// Extensions
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showIndicator() {
        Utilities.showActivityIndicator(view: self.view)
    }

    func closeIndicator() {
        Utilities.closeActivityIndicator()
    }
    
    func beginSignOutProcess() {
        if let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "landingNav") as? UINavigationController {
            self.present(nav, animated: true, completion: {
                DatabaseHandler
                Utilities.closeActivityIndicator()
            })
        }
    }
    
}


