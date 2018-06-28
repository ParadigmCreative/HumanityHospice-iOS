//
//  LoginViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    func masterSetup() {
        setupTextField()
        setupSignInButton()
        setupResetButton()
    }
    
    func setupTextField() {
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    func setupSignInButton() {
        signInButton.setupMainButton()
    }
    
    func setupResetButton() {
        resetPasswordButton.setupSecondaryButton()
        resetPasswordButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func verifyTextFields(completion: (String, String)->()) {
        
        var email: String?
        var pass: String?
        
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
            pass = p
        }
        
        completion(email!, pass!)
    }
    
    @IBAction func signIn(_ sender: Any) {
        verifyTextFields { (email, pass) in
            DatabaseHandler.signIn(email: email, password: pass, completion: { (user, error) in
                if error != nil {
                    self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                } else {
                    print("Login Successful", user!.email)
                    AppSettings.currentFBUser = user
                    DatabaseHandler.fetchData(for: user!, completion: {
                        let tabbar = UIStoryboard(name: "Main", bundle: nil)
                        if let tabbar = tabbar.instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
                            Utilities.closeActivityIndicator()
                            self.present(tabbar, animated: true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        // present view with textfield
        // if user alreadty entered email, grab text from tf and add to popup tf
        // two buttons, reset and cancel
        // show success message after 'reset'
        // close view
    
        let alert = UIAlertController(title: "Reset Password", message: "", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Email Address"
        }
        
        let reset = UIAlertAction(title: "Reset", style: .default) { (action) in
            var email: String = ""
            let tf = alert.textFields!.first!
            
            if self.emailTF.text!.isEmpty {
                if tf.text!.isEmpty {
                    // show alert
                } else {
                    email = tf.text!
                }
            } else {
                email = self.emailTF.text!
            }
            
            DatabaseHandler.reserPassword(email: email, completion: { (error) in
                if error != nil {
                    self.showAlert(title: "Oops!", message: "Please enter a valid email")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                    print("Email Sent")
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(reset)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            textField.resignFirstResponder()
        }
        
        return true
    }
    

}

extension UITextField {
    func setupTextField() {
        self.borderStyle = .none
    }
}
