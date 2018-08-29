//
//  SignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, InviteCodeDelegate {

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
    
    
    // MARK: - Invite Code
    private func showPopUp() {
        inviteCodePopUp.inviteCodeDelegate = self
        inviteCodePopUp.initialize()
        self.view.addSubview(inviteCodePopUp)
        inviteCodePopUp.center = self.view.center
        inviteCodePopUp.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.inviteCodePopUp.transform = CGAffineTransform.identity
        })
    }
    
    private func closePopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.inviteCodePopUp.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            self.inviteCodePopUp.removeFromSuperview()
        }
    }
    
    func invalidCode() {
        closePopup()
    }
    
    private var staticCode: String?
    private var followingPID: String?
    func validCode(code: String) {
        Utilities.showActivityIndicator(view: self.view)
        // Query DB
        DatabaseHandler.checkDBForInviteCode(code: code) { (success, pid) in
            if success {
                if let pid = pid {
//                    self.staticCode = code
                    self.followingPID = pid
                    AppSettings.currentPatient = pid
                    // show success
                    self.inviteCodePopUp.showSuccess()
                }
            } else {
                // show failure
                self.showAlert(title: "Hmm...", message: "That invite code doesn't exist.")
                Utilities.closeActivityIndicator()
            }
        }
    }
    
    func completed() {
        Utilities.closeActivityIndicator()
        closePopup()
        self.performSegue(withIdentifier: "showSignUp", sender: self.followingPID)
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if inviteCodePopUp.isHidden == false {
            if let touch = touches.first {
                if let view = touch.view {
                    if view != inviteCodePopUp {
                        closePopup()
                    }
                }
            }
        }
    }
    

}






















