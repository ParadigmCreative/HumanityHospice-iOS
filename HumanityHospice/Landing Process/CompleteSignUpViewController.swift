//
//  CompleteSignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class CompleteSignUpViewController: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var agreeToTermsButton: UIButton!
    
    var inviteCode: String?
    var pidToFollow: String?
    
    func masterSetup() {
        setupButtons()
        setupTextfields()
    }
    
    func setupButtons() {
        signUpButton.setupMainButton()
        signUpButton.isEnabled = false
        agreeToTermsButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0, right: 0)
    }
    
    
    
    func setupTextfields() {
        emailTF.delegate = self
        passwordTF.delegate = self
        reenterPasswordTF.delegate = self
    }
    
    @IBAction func agreeToTerms(_ sender: Any) {
        if agreeToTermsButton.isSelected {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox"), for: .normal)
            agreeToTermsButton.isSelected = false
            signUpButton.isEnabled = false
        } else {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox Filled"), for: .normal)
            agreeToTermsButton.isSelected = true
            signUpButton.isEnabled = true
        }
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
                                        print("Created new user:", appuser!.firstName, " ", appuser!.lastName)
                                        
                                        // SET CURRENT PATIENT
                                        if AppSettings.userType == DatabaseHandler.UserType.Reader {
                                            if let id = self.pidToFollow {
                                                DatabaseHandler.addUserToFollow(pid: id, userID: appuser!.id)
                                                AppSettings.currentPatient = id
                                                if var user = appuser as? DatabaseHandler.Reader {
                                                    user.readingFrom = id
                                                }
                                                print("Set currentPatient to:", id)
                                            }
                                        } else if AppSettings.userType == DatabaseHandler.UserType.Patient {
                                            AppSettings.currentPatient = AppSettings.currentFBUser!.uid
                                        }
                                        
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            reenterPasswordTF.becomeFirstResponder()
        } else if textField == reenterPasswordTF {
            textField.resignFirstResponder()
        }
        
        return true
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
