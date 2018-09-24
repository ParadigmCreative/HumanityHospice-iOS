//
//  SignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Outlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var patientButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    
    @IBOutlet var inviteCodePopUp: InviteCodePopUp!
    
    // MARK: - Setup
    
    func masterSetup() {
        setupButtons()
        
        if let nav = self.navigationController {
            nav.navigationBar.tintColor = .white
            nav.navigationBar.barTintColor = UIColor.clear
            nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
        }
        
    }
    
    func setupButtons() {
        
        patientButton.layer.cornerRadius = 5
        patientButton.setTitleColor(.white, for: .normal)
        
        friendButton.layer.cornerRadius = 5
        friendButton.setTitleColor(.white, for: .normal)
        
    }
    
    func setupTextFields() {
        firstName.delegate = self
        lastName.delegate = self
    }
    
    // MARK: - Class Functionality
    
    func verifyTextFields(completion: (String, String)->()) {
        
        var first: String?
        var last: String?
        
        if let e = firstName.text {
            guard e.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter your first name.")
                return
            }
            first = e
        }
        
        if let p = lastName.text {
            guard p.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter your last name.")
                return
            }
            last = p
        }
        
        completion(first!, last!)
    }
    
    @IBAction func patientSignUp(_ sender: Any) {
//        verifyTextFields { (first, last) in
//            let name = (first, last)
//            AppSettings.signUpName = name
            AppSettings.userType = DatabaseHandler.UserType.Patient
//
//        }
        performSegue(withIdentifier: "showSignUp", sender: "Patient")
    }
    
    @IBAction func friendSignUp(_ sender: Any) {
//        verifyTextFields { (first, last) in
//            showPopUp()
//            let name = (first, last)
//            AppSettings.signUpName = name
            AppSettings.userType = DatabaseHandler.UserType.Reader
//
//        }
        
        performSegue(withIdentifier: "showSignUp", sender: "Friend")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName {
            lastName.becomeFirstResponder()
        } else if textField == lastName {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    
    
    // MARK: Navigation
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            if let vc = segue.destination as? CompleteSignUpViewController {
                if let type = sender as? String {
                    vc.signupType = type
                }
            }
        }
    }

    

}






















