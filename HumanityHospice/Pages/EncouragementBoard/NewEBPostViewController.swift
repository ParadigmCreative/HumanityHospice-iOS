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
    
    var EBPostToEdit: EBPost?
    
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        messageTF.inputAccessoryView = toolbar
        messageTF.becomeFirstResponder()
        
        if let post = EBPostToEdit {
            messageTF.text = post.message
        }
        
        self.submitButton.setTitle("Send", for: .normal)
        
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
        checkTextView { (done, text) in
            if done {
                if EBPostToEdit == nil {
                    Utilities.showActivityIndicator(view: self.view)
                    let uid = AppSettings.currentAppUser!.id
                    let name = AppSettings.currentAppUser!.fullName()
                    DatabaseHandler.postEBToDatabase(posterID: uid, posterName: name, message: text!, completion: {
                        
                        NotificationDispatch.triggerNotification(for: .NewEncouragementPost)
                        
                        Utilities.closeActivityIndicator()
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    Utilities.showActivityIndicator(view: self.view)
                    if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
                        let postRef = DatabaseHandler.database.child(co.encouragementBoard.EncouragementBoards).child(reader.readingFrom)
                        postRef.child(EBPostToEdit!.id).updateChildValues(["Message": text!])
                        
                        NotificationDispatch.triggerNotification(for: .NewEncouragementPost)
                        
                        Utilities.closeActivityIndicator()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkTextView(completion: (Bool, String?)->()) {
        if let text = messageTF.text {
            if text.count > 0 {
                completion(true, text)
            } else {
                completion(false, nil)
            }
        }
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
