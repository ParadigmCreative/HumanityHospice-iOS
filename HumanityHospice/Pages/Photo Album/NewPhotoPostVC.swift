//
//  NewPhotoPostVC.swift
//  HumanityHospice
//
//  Created by App Center on 5/25/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit
import ImagePicker

class NewPhotoPostVC: UIViewController, UITextViewDelegate, ImagePickerDelegate {
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        openImagePicker()
    }
    
    func openImagePicker() {
        if self.imagePreview.image == nil {
            ImageSelector.open(with: self, delegate: self)
        } else  {
            messageTF.becomeFirstResponder()
        }
    }
    
    func showPermissionsAlert(title: String, message: String) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        
        let settings = UIAlertAction(title: "Settings", style: .default) { (alert) in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settings)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        messageTF.inputAccessoryView = toolbar
        setupImagePreview()
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
    
    func setupImagePreview() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imagePreview.isUserInteractionEnabled = true
        imagePreview.layer.cornerRadius = 10
        imagePreview.isHidden = true
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
    
//    func userDidSelectImage(image: UIImage) {
//        self.imagePreview.image = image
//        self.imagePreview.isHidden = false
//    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.imagePreview.image = images.first
        self.imagePreview.isHidden = false
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

        imagePicker.expandGalleryView()
        
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
