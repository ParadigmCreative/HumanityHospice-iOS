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
    
    @IBOutlet weak var submitPostButton: UIButton!
    @IBOutlet var toolbar: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var clearPhotoButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isInitial: Bool = true
    override func viewWillAppear(_ animated: Bool) {
        if isInitial {
            clearPhotoButton.isHidden = true
            addPhotoButton.isHidden = true
            selectPicture()
            isInitial = false
        } else {
            if imagePreview.image == nil {
                makeOutline()
                addPhotoButton.isHidden = false
                clearPhotoButton.isHidden = true
            } else {
                removeOutline()
                addPhotoButton.isHidden = true
                clearPhotoButton.isHidden = false
            }
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        selectPicture()
    }
    
    @IBAction func clearPhoto(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.clearPhotoButton.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.clearPhotoButton.isHidden = true
        })
        
        DispatchQueue.main.async {
            self.imagePreview.image = nil
            self.addPhotoButton.isHidden = false
            self.makeOutline()
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
        setupImagePreview()
    }
    
    @IBOutlet weak var imageArea: UIView!
    func makeOutline() {
        imageArea.layer.borderWidth = 1
        imageArea.layer.borderColor = #colorLiteral(red: 0.4588235294, green: 0.4470588235, blue: 0.7568627451, alpha: 1)
    }
    
    func removeOutline() {
        imageArea.layer.borderColor = nil
        imageArea.layer.borderWidth = 0
    }
    
    func setupButtons() {
        cancelButton.backgroundColor = #colorLiteral(red: 1, green: 0.1058823529, blue: 0.003921568627, alpha: 1)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.layer.cornerRadius = 15
        cancelButton.setTitle("Done", for: .normal)
        
        submitPostButton.layer.cornerRadius = 10
    }
    
    
    func setupImagePreview() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        imagePreview.isUserInteractionEnabled = true
        imagePreview.layer.cornerRadius = 10
        imagePreview.isHidden = true
        imagePreview.clipsToBounds = true
        imagePreview.addGestureRecognizer(tapGest)
    }
    
    @objc func viewImage() {
        guard let img = imagePreview.image else { return }
        ImageViewer.initialize(image: img, text: "", isFromJournal: true)
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
            self.cancelButton.isEnabled = false
            self.submitPostButton.isEnabled = false
            self.exitButton.isEnabled = false
            
            if let img = self.imagePreview.image {
                self.showProgress()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                DatabaseHandler.postImageToStorage(image: img, caption: nil, completion: { (error) in
                    self.hideProgess()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Posted image to storage")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
                DatabaseHandler.manageUpload(monitoring: { (task) in
                    let complete = Float(task.progress!.completedUnitCount)
                    let total = Float(task.progress!.totalUnitCount)
                    let percent = (complete / total)
                    self.progressBar.setProgress(percent, animated: true)
                    
                })
            }
         
        }
    }
    
    
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


extension NewPhotoPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        let alert = UIAlertController(title: "Please select an option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        self.imagePreview.image = newImage
        self.imagePreview.isHidden = false
        self.clearPhotoButton.transform = CGAffineTransform.identity
        self.clearPhotoButton.isHidden = false
        self.view.bringSubview(toFront: self.clearPhotoButton)
        
        dismiss(animated: true)
    }
    
}

