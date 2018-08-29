//
//  NewPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit
import ImagePicker

class NewPostViewController: UIViewController, UITextViewDelegate, ImagePickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
    }
    
    // MARK: - Properties
    
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
    
    
    // MARK: - Setup
    func setup() {
        setupButtons()
        clearPhotoButton.isHidden = true
        messageTF.inputAccessoryView = toolbar
        setupImagePreview()
        messageTF.becomeFirstResponder()
    }
    
    func setupImagePreview() {
        imagePreview.isHidden = true
        imagePreview.clipsToBounds = true
        imagePreview.layer.cornerRadius = 5
        setupImagePreviewGesture()
    }
    
    func setupButtons() {
        attachPhotoButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.4039215686, blue: 0.7254901961, alpha: 1)
        attachPhotoButton.setTitleColor(UIColor.white, for: .normal)
        attachPhotoButton.titleLabel?.textAlignment = .center
        attachPhotoButton.layer.cornerRadius = attachPhotoButton.frame.height / 2
        
        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 0.1058823529, blue: 0.003921568627, alpha: 1)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        
        submitPostButton.layer.cornerRadius = submitPostButton.frame.height / 2
    }
    
    func setupToolbar() {
        messageTF.delegate = self
        toolbar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    func setupImagePreviewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imagePreview.isUserInteractionEnabled = true
        imagePreview.addGestureRecognizer(tap)
    }
    
    @objc func viewImage() {
        guard let img = self.imagePreview.image else { return }
        ImageViewer.initialize(image: img, text: "")
        ImageViewer.open(vc: self)
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
        
        messageTF.becomeFirstResponder()
    }
    
    @IBAction func submitPost(_ sender: Any) {
        print("POST!")
        
//        Utilities.showActivityIndicator(view: self.view)
        
        self.cancelButton.isEnabled = false
        self.submitPostButton.isEnabled = false
        self.attachPhotoButton.isEnabled = false
        var message: String = messageTF.text ?? ""
        
        if self.imagePreview.image == nil {
            var name: String = ""
            
            if AppSettings.userType == .Family {
                if let user = AppSettings.currentAppUser as? DatabaseHandler.Family {
                    if let patient = user.patientObj {
                        name = "\(patient.firstName) \(patient.lastName)"
                    }
                }
            } else {
                name = "\(AppSettings.currentAppUser!.firstName) \(AppSettings.currentAppUser!.lastName)"
            }
            DatabaseHandler.postToDatabase(posterUID: AppSettings.currentPatient!,
                                           posterName: name,
                                           message: message,
                                           imageURL: nil,
                                           completion: {
                                            Utilities.closeActivityIndicator()
                                            self.dismiss(animated: true, completion: nil)})
        } else {
            let name = "\(AppSettings.currentAppUser!.firstName) \(AppSettings.currentAppUser!.lastName)"
            if let img = self.imagePreview.image {
                
                showProgress()
                
                DatabaseHandler.postImageToDatabase(image: img, completion: { (url, error) in
                    self.hideProgess()
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        DatabaseHandler.postToDatabase(posterUID: AppSettings.currentPatient!,
                                                       posterName: name,
                                                       message: message,
                                                       imageURL: url!, completion: {
                            Utilities.closeActivityIndicator()
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
                
                DatabaseHandler.manageJournalImageUpload { (snap) in
                    let percent = Float(snap.progress!.fractionCompleted)
                    self.progressBar.setProgress(percent, animated: true)
                }
                
            }
            
        }

    }
    
    @IBAction func attachPhoto(_ sender: Any) {
//        ImageSelector.open(with: self, delegate: self)
        var config = Configuration()
        config.noImagesTitle = "Loading images..."
        config.requestPermissionTitle = "Attention!"
        let picker = ImagePickerController(configuration: config)
        picker.imageLimit = 1
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.messageTF.resignFirstResponder()
    }
    
    // MARK: - Delegate Responders
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.image = images.first!
        self.imagePreview.isHidden = false
        self.clearPhotoButton.transform = CGAffineTransform.identity
        self.clearPhotoButton.isHidden = false
        imagePicker.dismiss(animated: true) {
            self.view.bringSubview(toFront: self.clearPhotoButton)
        }
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.expandGalleryView()
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Utilities
    
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
    
    // MARK: - UploadTask
    
    @IBOutlet var bg: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    func showProgress() {
        self.view.addSubview(self.bg)
        bg.center = self.view.center
        bg.layer.cornerRadius = 5
        
        progressBar.setProgress(0.01, animated: true)
        
        activityView.startAnimating()
        
        bg.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.3) {
            self.bg.transform = CGAffineTransform.identity
        }
    }
    
    func hideProgess() {
        activityView.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.bg.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            self.bg.removeFromSuperview()
        }
    }
    
    

}
