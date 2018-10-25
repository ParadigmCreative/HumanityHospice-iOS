//
//  Utilities.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class Utilities {
    public static var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
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
        return indicator
    }
}




// Extensions
extension UIViewController {
    @objc func showAlert(title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
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
        RealmHandler.resetPhotoAlbum()
        RealmHandler.resetJournalPosts()
        RealmHandler.resetComments()
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

extension TimeInterval {
    public func toTimeStamp() -> String {
        let timeint = self
        let day = TimeInterval(60 * 60 * 24.0)
        let now = Date().timeIntervalSince1970


        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale.current

        let calendar = Calendar(identifier: .gregorian)

        let morning = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let morningInt = morning!.timeIntervalSince1970

        let yesterdayTimeInt = now - day
        let yesterdayDate = Date(timeIntervalSince1970: yesterdayTimeInt)
        let yesterday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: yesterdayDate)
        let yesterdayInt = yesterday!.timeIntervalSince1970

        var timestamp = ""

        if timeint > morningInt {
            formatter.dateStyle = .none
            let date = Date(timeIntervalSince1970: timeint)
            let str = formatter.string(from: date)
            timestamp = "Today, \(str)"
        } else if timeint < morningInt && timeint > yesterdayInt {
            formatter.dateStyle = .none
            let date = Date(timeIntervalSince1970: timeint)
            let str = formatter.string(from: date)
            timestamp = "Yesterday, \(str)"
        } else if timeint < yesterdayInt {
            let date = Date(timeIntervalSince1970: timeint)
            let str = formatter.string(from: date)
            formatter.dateFormat = "MMM dd"
            let dateStr = formatter.string(from: date)
            timestamp = "\(dateStr), \(str)"
        }

        return timestamp

    }
}
