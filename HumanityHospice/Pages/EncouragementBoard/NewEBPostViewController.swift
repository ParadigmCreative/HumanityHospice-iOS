//
//  NewEBPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/9/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class NewEBPostViewController: UIViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var messageTF: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var toolbar: UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    
    
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        messageTF.inputAccessoryView = toolbar
        messageTF.becomeFirstResponder()
    }
    
    func setupButtons() {

        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 0.1058823529, blue: 0.003921568627, alpha: 1)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.layer.cornerRadius = 15
        
        submitButton.layer.cornerRadius = 10
    }
    
    func setupToolbar() {
        messageTF.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    

    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func submitPost(_ sender: Any) {
        
    }
    
    @IBAction func exit(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setupToolbar()
    }

}
