//
//  CreateFamilyAccount.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class CreateFamilyAccount: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass1: UITextField!
    @IBOutlet weak var pass2: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var agreeToTermsButton: UIButton!
    @IBOutlet var successView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MenuHandler.staticMenu?.setHandingController(vc: self)
        print("Family")
        setup()
        
        
    }
    
    func setup() {
        signupButton.setupMainButton()
        signupButton.backgroundColor = .clear
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        pass1.delegate = self
        pass2.delegate = self
        signupButton.isEnabled = false
        
        agreeToTermsButton.layer.cornerRadius = 5
        agreeToTermsButton.layer.borderWidth = 2
        agreeToTermsButton.layer.borderColor = UIColor.white.cgColor
    }

    func createFamilyAccount(first: String, last: String, email: String, password: String) {
        checkTextView { (first, last, email, pass) in
            print(first, last, email, pass)
        }
    }
    
    func checkTextView(completion: (String, String, String, String)->()) {
        guard firstName.text!.count > 0 else {
            self.showAlert(title: "Hmm...", message: "Please enter a first name")
            return
        }
        guard lastName.text!.count > 0 else {
            self.showAlert(title: "Hmm...", message: "Please enter a last name")
            return
        }
        guard email.text!.count > 0 else {
            self.showAlert(title: "Hmm...", message: "Please enter a valid email")
            return
        }
        guard pass1.text!.count > 0 else {
            self.showAlert(title: "Hmm...", message: "Please enter a valid password")
            return
        }
        guard pass2.text!.count > 0 else {
            self.showAlert(title: "Hmm...", message: "Please re enter your password")
            return
        }
        
        guard let first = firstName.text else { return }
        guard let last = lastName.text else { return }
        guard let email = email.text else { return }
        guard pass1.text == pass2.text else {
            self.showAlert(title: "Hmm...", message: "Your passwords do not match.")
            return
        }
        
        guard let pass = pass1.text else { return }
        
        completion(first, last, email, pass)
        
    }
    
    func showVerificationAlert(member: String, completion: @escaping (Bool)->()) {
        let alert = UIAlertController(title: "Attention!", message: "Are you sure you want to add \(member) as a family member?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (alert) in
            completion(true)
        }
        
        let no = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            completion(false)
        }
        
        alert.addAction(yes)
        alert.addAction(no)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func agreeToTerms(_ sender: Any) {
        if agreeToTermsButton.isSelected {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox"), for: .normal)
            agreeToTermsButton.isSelected = false
            signupButton.isEnabled = false
        } else {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox Filled"), for: .normal)
            agreeToTermsButton.isSelected = true
            signupButton.isEnabled = true
        }
    }
    
    @IBAction func createFamilyAccount(_ sender: Any) {
        checkTextView { (first, last, email, pass) in
            showVerificationAlert(member: first, completion: { (verified) in
                if verified {
                    Utilities.showActivityIndicator(view: self.view)
                    DatabaseHandler.createFamilAccount(first: first, last: last, email: email, pass: pass, completion: { (error) in
                        if error != nil {
                            Utilities.closeActivityIndicator()
                            self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                        } else {
                            print("Done creating family account!")
                            Utilities.closeActivityIndicator()
                            self.clearFields()
                            self.showConfirmation()
                        }
                    })
                } else {
                    print("Cancelled")
                }
            })
        }
    }
    
    func clearFields() {
        firstName.text = ""
        lastName.text = ""
        email.text = ""
        pass1.text = ""
        pass2.text = ""
    }
    
    private func showConfirmation() {
        self.view.addSubview(successView)
        let center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        successView.center = center
        successView.layer.cornerRadius = 5
        successView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.15, animations: {
            self.successView.transform = CGAffineTransform.identity
        }) { (done) in
            if done {
                Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { (timer) in
                    self.closeConfirmation()
                })
            }
        }
    }
    
    private func closeConfirmation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.successView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            if done {
                self.successView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        MenuHandler.openMenu(vc: self)
    }
    
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstName {
            lastName.becomeFirstResponder()
        } else if textField == lastName {
            email.becomeFirstResponder()
        } else if textField == email {
            pass1.becomeFirstResponder()
        } else if textField == pass1 {
            pass2.becomeFirstResponder()
        } else if textField == pass2 {
            textField.resignFirstResponder()
        }
        
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}












