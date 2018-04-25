//
//  InviteCodePopUp.swift
//  HumanityHospice
//
//  Created by App Center on 4/24/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class InviteCodePopUp: UIView, UITextFieldDelegate {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var successLabel: UILabel?
    
    var inviteCodeDelegate: InviteCodeDelegate?
    
    func initialize() {
        setupView()
        setupTitle()
        setupButton()
    }
    
    private func setupView() {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
    private func setupTitle() {
        let systemFont = UIFont.systemFont(ofSize: 35.0, weight: UIFont.Weight.light)
        let smallCapsDesc = systemFont.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                 UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector]]
            ])
        let font = UIFont(descriptor: smallCapsDesc, size: systemFont.pointSize)
        
        headerLabel.font = font
        headerLabel.textColor = UIColor.white
    }
    
    private func setupButton() {
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 5
    }
    
    private func setupSuccessLabel() {
        self.successLabel = UILabel(frame: self.headerLabel.frame)
        self.successLabel?.adjustsFontSizeToFitWidth = true
        self.successLabel?.text = "Success!"
        
        let systemFont = UIFont.systemFont(ofSize: 35.0, weight: UIFont.Weight.light)
        let smallCapsDesc = systemFont.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                 UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector]]
            ])
        let font = UIFont(descriptor: smallCapsDesc, size: systemFont.pointSize)
        
        self.successLabel?.font = font
        self.successLabel?.textColor = UIColor.white
    }
    
    func showSuccess() {
        UIView.animate(withDuration: 0.3, animations: {
            self.headerLabel.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.headerLabel.center = self.codeTF.center
            
            self.codeTF.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            
            self.submitButton.isEnabled = false
            self.submitButton.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.submitButton.center = self.codeTF.center
            
        }) { (done) in
            self.headerLabel.isHidden = true
            self.codeTF.isHidden = true
            self.submitButton.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.setupSuccessLabel()
                self.addSubview(self.successLabel!)
                self.successLabel?.center = self.center
            }, completion: { (done) in
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
                    self.inviteCodeDelegate?.completed()
                })
            })
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        if let text = codeTF.text {
            if text.count == 5 {
                inviteCodeDelegate?.validCode(code: text)
            } else {
                inviteCodeDelegate?.invalidCode()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == codeTF {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

protocol InviteCodeDelegate {
    func invalidCode()
    func validCode(code: String)
    func completed()
}
