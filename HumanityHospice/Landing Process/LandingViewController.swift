//
//  LandingViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import Firebase

class LandingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Utilities.showActivityIndicator(view: self.view)
        if Auth.auth().currentUser != nil {
            AppSettings.currentFBUser = Auth.auth().currentUser
            if let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
                DatabaseHandler.fetchData(for: AppSettings.currentFBUser!, completion: {
                    Utilities.closeActivityIndicator()
                    self.present(tabbar, animated: true, completion: nil)
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createNewAccountButton: UIButton!
    @IBOutlet weak var copywriteLabel: UILabel!
    
    fileprivate func masterSetup() {
        setupTitle()
        setupCreateNewAccountButton()
        setupSignInButton()
        setupCopywrite()
    }
    
    func setupTitle() {
        let systemFont = UIFont.systemFont(ofSize: 35.0, weight: UIFont.Weight.light)
        let smallCapsDesc = systemFont.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                 UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector]]
            ])
        let font = UIFont(descriptor: smallCapsDesc, size: systemFont.pointSize)
        
        titleLabel.font = font
        titleLabel.textColor = UIColor.gray
    }
    
    func setupSignInButton() {
        signInButton.setupMainButton()
    }
    
    func setupCreateNewAccountButton() {
        createNewAccountButton.setupSecondaryButton()
    }
    
    func setupCopywrite() {
        copywriteLabel.textColor = UIColor.lightGray
    }
    
    
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIButton {
    func setupMainButton() {
        self.layer.cornerRadius = 5
        self.backgroundColor = #colorLiteral(red: 0.4605029225, green: 0.447249949, blue: 0.7566576004, alpha: 1)
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setupSecondaryButton() {
        self.setTitleColor(#colorLiteral(red: 0.4605029225, green: 0.447249949, blue: 0.7566576004, alpha: 1), for: .normal)
    }
}
