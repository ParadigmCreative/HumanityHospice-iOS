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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MenuHandler.staticMenu?.setHandingController(vc: self)
        print("Family")
        setup()
        
        
    }
    
    func setup() {
        signupButton.setupMainButton()
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        pass1.delegate = self
        pass2.delegate = self
        
    }

    func createFamilyAccount(first: String, last: String, email: String, password: String) {
        checkTextView { (first, last, email, pass) in
            print(first, last, email, pass)
        }
    }
    
    func checkTextView(completion: (String, String, String, String)->()) {
        guard firstName.text!.count > 0 else { return }
        guard lastName.text!.count > 0 else { return }
        guard email.text!.count > 0 else { return }
        guard pass1.text!.count > 0 else { return }
        guard pass2.text!.count > 0 else { return }
        
        guard let first = firstName.text else { return }
        guard let last = lastName.text else { return }
        guard let email = email.text else { return }
        guard pass1.text == pass2.text else { return }
        
        guard let pass = pass1.text else { return }
        
        completion(first, last, email, pass)
        
    }
    
    func showVerificationAlert(completion: @escaping (Bool)->()) {
        let alert = UIAlertController(title: "Attention!", message: "Are you sure you want to post to the Journal?", preferredStyle: .alert)
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
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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

    
}












