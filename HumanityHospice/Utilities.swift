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
        UIApplication.shared.beginIgnoringInteractionEvents()
        view.addSubview(indicator)
        self.indicator.startAnimating()
    }
    
    public static func closeActivityIndicator() {
        UIApplication.shared.endIgnoringInteractionEvents()
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
    
    public static func createActivityIndicator(view: UIView) -> UIActivityIndicatorView {
        var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.color = #colorLiteral(red: 0.4605029225, green: 0.447249949, blue: 0.7566576004, alpha: 1)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        indicator.startAnimating()
        return indicator
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
        DatabaseHandler.signOut()
        if let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "landingNav") as? UINavigationController {
            self.present(nav, animated: true, completion: {
                Utilities.closeActivityIndicator()
            })
        }
    }
    
}

extension UIFont {
    func setFont() -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.light)
        let smallCapsDesc = systemFont.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                 UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector]]
            ])
        let font = UIFont(descriptor: smallCapsDesc, size: systemFont.pointSize)
        
        return font
    }
}


