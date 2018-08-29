//
//  CompleteSignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class CompleteSignUpViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Outlets
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var reenterPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var agreeToTermsButton: UIButton!
    @IBOutlet weak var patientCode: UITextField!
    
    var inviteCode: String?
    var pidToFollow: String?
    var signupType: String = ""
    
    // MARK: - Setup
    func masterSetup() {
        setupButtons()
        setupTextfields()
        if signupType == "Patient" {
            patientCode.isEnabled = false
            patientCode.isHidden = true
            self.title = "I am a Patient"
        } else {
            self.title = "I am a Friend of a Patient"
        }
        
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func setupButtons() {
        signUpButton.setupMainButton()
        signUpButton.isEnabled = false
        agreeToTermsButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0, right: 0)
        agreeToTermsButton.layer.cornerRadius = 5
        agreeToTermsButton.layer.borderColor = UIColor.white.cgColor
        agreeToTermsButton.layer.borderWidth = 2
    }
    
    
    
    func setupTextfields() {
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        reenterPasswordTF.delegate = self
        patientCode.delegate = self
    }
    
    // MARK: - Actions
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

    
    @IBAction func signUp(_ sender: Any) {
        self.showIndicator()
        verifyTextFields { (first, last, email, pass) in
            
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
                        AppSettings.signUpName = (first, last)
                        // make profile changes to user
                        let changes = user?.createProfileChangeRequest()
                        changes?.displayName = "\(first) \(last)"
                        
                        changes?.commitChanges(completion: { (error) in
                            if error != nil {
                                // show alert if there was an error
                                self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                                self.closeIndicator()
                            } else {
                                print("New User:", user!.uid, user!.email!, user!.displayName!)
                                
                                // create app user instance
                                let appuser = DatabaseHandler.createAppUser(user: user!)
                                
                                // create DB reference with user data
                                DatabaseHandler.createUserReference(type: AppSettings.userType!, user: appuser!, completion: { (error, done) in
                                    if error != nil {
                                        self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                                        self.closeIndicator()
                                    } else {
                                        print("Created new user:", appuser!.firstName, appuser!.lastName)
                                        
                                        // SET CURRENT PATIENT
                                        if AppSettings.userType == DatabaseHandler.UserType.Reader {
                                            if let id = self.pidToFollow {
                                                DatabaseHandler.addUserToFollow(pid: id, userID: appuser!.id)
                                                AppSettings.currentPatient = id
                                                if var user = appuser as? DatabaseHandler.Reader {
                                                    user.readingFrom = id
                                                    AppSettings.currentAppUser = user
                                                }
                                                print("Set currentPatient to:", id)
                                            }
                                        } else if AppSettings.userType == DatabaseHandler.UserType.Patient {
                                            AppSettings.currentPatient = AppSettings.currentFBUser!.uid
                                            
                                            // make first post
                                            DatabaseHandler.postToDatabase(posterUID: user!.uid,
                                                                           posterName: user!.displayName!,
                                                                           message: "\(user!.displayName!) has joined Humanity Hospice",
                                                                           imageURL: nil,
                                                                           completion: {})
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
    
    // MARK: - Textfield
    func verifyTextFields(completion: (_ first: String, _ last: String, _ email: String, _ password: String)->()) {
        
        if let f = firstNameTF.text, let l = lastNameTF.text, let e = emailTF.text, let p1 = passwordTF.text, let p2 = reenterPasswordTF.text {
            
            guard f.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your first name")
                return
            }
            
            guard l.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your last name")
                return
            }
            
            guard e.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter a valid email address.")
                return
            }
            
            guard p1.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your password.")
                return
            }
            
            guard p2.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please re-enter your password.")
                return
            }
            
            if p1 == p2 {
                completion(f, l, e, p1)
            } else {
                self.showAlert(title: "Oops!", message: "Passwords do not match.")
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF {
            lastNameTF.becomeFirstResponder()
        } else if textField == lastNameTF {
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            reenterPasswordTF.becomeFirstResponder()
        } else if textField == reenterPasswordTF {
            if patientCode.isHidden {
                textField.resignFirstResponder()
            } else {
                patientCode.becomeFirstResponder()
            }
        } else if textField == patientCode {
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
