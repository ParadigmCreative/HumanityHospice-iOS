//
//  LoginViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

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
        emailTF.setupTextField()
        passwordTF.setupTextField()
    }
    
    func setupSignInButton() {
        signInButton.setupMainButton()
    }
    
    func setupResetButton() {
        resetPasswordButton.setupSecondaryButton()
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
                    DatabaseHandler.fetchData(for: user!)
                    let tabbar = UIStoryboard(name: "Main", bundle: nil)
                    if let tabbar = tabbar.instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
                        self.present(tabbar, animated: true, completion: nil)
                    }
                }
            })
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

extension UITextField {
    func setupTextField() {
        self.borderStyle = .none
    }
}
