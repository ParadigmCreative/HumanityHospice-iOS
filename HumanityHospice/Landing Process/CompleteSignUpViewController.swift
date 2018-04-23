//
//  CompleteSignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class CompleteSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var reenterPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    func masterSetup() {
        setupButtons()
        setupTextfields()
    }
    
    func setupButtons() {
        signUpButton.setupMainButton()
    }
    
    func setupTextfields() {
        emailTF.setupTextField()
        passwordTF.setupTextField()
        reenterPasswordTF.setupTextField()
    }
    
    func verifyTextFields(completion: (String, String)->()) {
        
        var email: String?
        var password: String?
        var pass2: String?
        
        if let e = emailTF.text {
            guard e.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter a valid email address.")
                return
            }
            email = e
        }
        
        if let p = passwordTF.text {
            guard p.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter your password.")
                return
            }
            password = p
        }
        
        if let p = reenterPasswordTF.text {
            guard p.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please re-enter your password.")
                return
            }
            pass2 = p
        }
        
        if password == pass2 {
            completion(email!, password!)
        } else {
            self.showAlert(title: "Oops!", message: "Passwords do not match.")
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        self.showIndicator()
        verifyTextFields { (email, pass) in
            // Sign up user
            DatabaseHandler.signUp(email: email, password: pass, completion: { (user, error) in
                if error != nil {
                    // show alert if error isn't nil
                    self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                    self.closeIndicator()
                } else {
                    if user != nil {
                        // set current user to user handed back from call
                        AppSettings.currentFBUser = user
                        
                        // make profile changes to user
                        let changes = user?.createProfileChangeRequest()
                        changes?.displayName = "\(AppSettings.signUpName!.first) \(AppSettings.signUpName!.last)"
                        changes?.commitChanges(completion: { (error) in
                            if error != nil {
                                
                                // show alert if there was an error
                                self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                                self.closeIndicator()
                            } else {
                                print("New User:", user!.uid, user!.email, user!.displayName)
                                
                                // create app user instance
                                let appuser = DatabaseHandler.createAppUser(user: user!)
                                
                                // create DB reference with user data
                                DatabaseHandler.createUserReference(type: AppSettings.userType!, user: appuser!, completion: { (error, done) in
                                    if error != nil {
                                        self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                                        self.closeIndicator()
                                    } else {
                                        print("Created new user:", appuser!.firstName)
                                        
                                        // if creation is successful, set
                                        AppSettings.currentAppUser = appuser
                                        
                                        // Present the Journal View
                                        self.closeIndicator()
                                        self.moveToJournal()
                                    }
                                })
                            }
                        })
                    } else {
                        self.closeIndicator()
                        self.showAlert(title: "Hmm...", message: "Something happend. Please try again later")
                    }
                }
            })
        }
    }
    
    
    func moveToJournal() {
        if let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
           self.present(tabbar, animated: true, completion: nil)
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