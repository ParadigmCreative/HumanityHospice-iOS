//
//  SignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var patientButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    
    func masterSetup() {
        setupButtons()
        setupTextFields()
    }
    
    func setupButtons() {
        patientButton.setupMainButton()
        friendButton.setupMainButton()
    }
    
    func setupTextFields() {
        firstName.setupTextField()
        lastName.setupTextField()
    }
    
    func verifyTextFields(completion: (String, String)->()) {
        
        var first: String?
        var last: String?
        
        if let e = firstName.text {
            guard e.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter a valid email address.")
                return
            }
            first = e
        }
        
        if let p = lastName.text {
            guard p.count > 0 else {
                self.showAlert(title: "Oops!", message: "Please enter your password.")
                return
            }
            last = p
        }
        
        completion(first!, last!)
    }
    
    @IBAction func patientSignUp(_ sender: Any) {
        verifyTextFields { (first, last) in
            let name = (first, last)
            AppSettings.signUpName = name
            AppSettings.userType = DatabaseHandler.UserType.Patient
            performSegue(withIdentifier: "showSignUp", sender: self)
        }
    }
    
    @IBAction func friendSignUp(_ sender: Any) {
        AppSettings.userType = DatabaseHandler.UserType.Reader
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
