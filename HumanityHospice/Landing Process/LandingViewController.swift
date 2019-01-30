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

//        try! Auth.auth().signOut()
        
        masterSetup()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Utilities.showActivityIndicator(view: self.view)
        
        checkForLoggedinUser { (user) in
            if user != nil {
                AppSettings.currentFBUser = Auth.auth().currentUser
                DatabaseHandler.fetchData(for: AppSettings.currentFBUser!, completion: {
                    Utilities.closeActivityIndicator()
                    if AppSettings.userType == .Staff {
                        guard VideoCallDatabaseHandler.deviceToken.isEmpty == false else { return }
                        CallManager.goOnline(with: VideoCallDatabaseHandler.deviceToken)
                        
                        let nav = UINavigationController()
                        self.present(nav, animated: true, completion: nil)
                        let nurseCoordinator = NurseCoordinator(nav: nav)
                        nurseCoordinator.start()
                        
                    } else {
                        if let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
                            self.present(tabbar, animated: true, completion: nil)
                        }
                    }
                })
            } else {
                Utilities.closeActivityIndicator()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createNewAccountButton: UIButton!
    @IBOutlet weak var copywriteLabel: UILabel!
    
    fileprivate func masterSetup() {
        setupCreateNewAccountButton()
        setupSignInButton()
        setupCopywrite()
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
    
    @IBAction func gotoLogin(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    
    private func checkForLoggedinUser(completion: (User?)->()) {
        if let user = Auth.auth().currentUser {
            completion(user)
        } else {
            completion(nil)
        }
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
        self.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4470588235, blue: 0.7568627451, alpha: 1)
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setupSecondaryButton() {
        self.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4470588235, blue: 0.7568627451, alpha: 1), for: .normal)
    }
}
