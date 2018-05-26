//
//  NewPhotoPostVC.swift
//  HumanityHospice
//
//  Created by App Center on 5/25/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class NewPhotoPostVC: UIViewController, UITextViewDelegate, ImageSelectorDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    @IBOutlet weak var messageTF: UITextView!
    @IBOutlet weak var submitPostButton: UIButton!
    @IBOutlet var toolbar: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
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
    
    override func viewDidAppear(_ animated: Bool) {
        if self.imagePreview.image == nil {
            ImageSelector.open(vc: self)
        } else  {
            messageTF.becomeFirstResponder()
        }
    }
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        clearPhotoButton.isHidden = true
        messageTF.inputAccessoryView = toolbar
        imagePreview.layer.cornerRadius = 10
        imagePreview.isHidden = true
        setupImagePreview()
        ImageSelector.delegate = self
    }
    
    func setupButtons() {
        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 0.1058823529, blue: 0.003921568627, alpha: 1)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.layer.cornerRadius = 15
        cancelButton.setTitle("Done", for: .normal)
        
        submitPostButton.layer.cornerRadius = 10
    }
    
    func setupToolbar() {
        messageTF.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(35)
        }
        
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
        
    
    func setupImagePreview() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imagePreview.isUserInteractionEnabled = true
        imagePreview.addGestureRecognizer(tapGest)
    }
    
    @objc func viewImage() {
        guard let img = imagePreview.image else { return }
        ImageViewer.initialize(image: img, text: "")
        ImageViewer.open(vc: self)
    }
    
    // MARK: - Actions
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPost(_ sender: Any) {
        
        if self.imagePreview.image == nil {
            self.showAlert(title: "Oops!", message: "Please select an image to add to your photo album.")
        } else {
            self.showVerificationAlert(completion: { (confirmed) in
                Utilities.showActivityIndicator(view: self.view)
                if confirmed {
                    self.cancelButton.isEnabled = false
                    self.submitPostButton.isEnabled = false
                    self.exitButton.isEnabled = false
                    
                    if let img = self.imagePreview.image {
                        self.checkTextView { (hasText, message) in
                            DatabaseHandler.postImageToStorage(image: img, caption: message, completion: { (error) in
                                Utilities.closeActivityIndicator()
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else {
                                    print("Posted image to storage")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                } else {
                    Utilities.closeActivityIndicator()
                }
            })
        }
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
