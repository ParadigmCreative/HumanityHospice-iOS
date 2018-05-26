//
//  NewPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class NewPostViewController: UIViewController, UITextViewDelegate, ImageSelectorDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
    }
    
    @IBOutlet weak var messageTF: UITextView!
    @IBOutlet weak var submitPostButton: UIButton!
    @IBOutlet var toolbar: UIView!
    @IBOutlet weak var attachPhotoButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    var image: UIImage? {
        didSet {
            self.imagePreview.image = self.image
            self.clearPhotoButton.isHidden = false
        }
    }
    @IBOutlet weak var clearPhotoButton: UIButton!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        clearPhotoButton.isHidden = true
        messageTF.inputAccessoryView = toolbar
        imagePreview.isHidden = true
        messageTF.becomeFirstResponder()
    }
    
    func setupButtons() {
        attachPhotoButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.4039215686, blue: 0.7254901961, alpha: 1)
        attachPhotoButton.setTitleColor(UIColor.white, for: .normal)
        attachPhotoButton.titleLabel?.textAlignment = .center
        attachPhotoButton.layer.cornerRadius = 15
        
        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 0.1058823529, blue: 0.003921568627, alpha: 1)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.layer.cornerRadius = 15
        
        submitPostButton.layer.cornerRadius = 10
    }
    
    func setupToolbar() {
        messageTF.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(35)
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearPhoto(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.clearPhotoButton.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.clearPhotoButton.isHidden = true
        })
        
        DispatchQueue.main.async {
            self.imagePreview.image = nil
            self.image = nil
        }
    }
    
    @IBAction func submitPost(_ sender: Any) {
        print("POST!")
        
        checkTextView { (verified, message) in
            if verified {
                self.showVerificationAlert(completion: { (confirmed) in
                    Utilities.showActivityIndicator(view: self.view)
                    if confirmed {
                        self.cancelButton.isEnabled = false
                        self.submitPostButton.isEnabled = false
                        self.attachPhotoButton.isEnabled = false
                        
                        if self.imagePreview.image == nil {
                            let name = "\(AppSettings.currentAppUser!.firstName) \(AppSettings.currentAppUser!.lastName)"
                            DatabaseHandler.postToDatabase(poster: AppSettings.currentPatient!,
                                                           name: name,
                                                           message: message!,
                                                           imageURL: nil,
                                                           completion: {
                                                            Utilities.closeActivityIndicator()
                                                            self.dismiss(animated: true, completion: nil)
                            })
                        } else {
                            let name = "\(AppSettings.currentAppUser!.firstName) \(AppSettings.currentAppUser!.lastName)"
                            if let img = self.imagePreview.image {
                                DatabaseHandler.postImageToDatabase(image: img, completion: { (url, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        DatabaseHandler.postToDatabase(poster: AppSettings.currentPatient!, name: name, message: message!, imageURL: url!, completion: {
                                            Utilities.closeActivityIndicator()
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                })
                            }
                            
                        }
                    }
                })
            } else {
                showAlert(title: "Hmm...", message: "Please make sure you've ")
            }
        }
    }
    
    @IBAction func attachPhoto(_ sender: Any) {
        ImageSelector.delegate = self
        ImageSelector.open(vc: self)
    }
    
    func userDidSelectImage(image: UIImage) {
        self.image = image
        self.imagePreview.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.clearPhotoButton.transform = CGAffineTransform.identity
            self.clearPhotoButton.isHidden = false
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.messageTF.resignFirstResponder()
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
    
    
    // MARK: - Text View
    func textViewDidBeginEditing(_ textView: UITextView) {
        setupToolbar()
    }
    
    

}
