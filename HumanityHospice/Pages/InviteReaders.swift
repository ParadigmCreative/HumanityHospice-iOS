//
//  InviteReaders.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class InviteReaders: UIViewController {

    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessCodeButton: UIButton!
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var URLButton: UIButton!
    @IBOutlet weak var shareAccessCodeButton: UIButton!
    @IBOutlet weak var shareWebURLButton: UIButton!
    @IBOutlet var copyConfirmationView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MenuHandler.staticMenu?.setHandingController(vc: self)
        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setup() {
        accessCodeButton.layer.borderColor = UIColor.gray.cgColor
        accessCodeButton.layer.borderWidth = 1
        accessCodeButton.layer.cornerRadius = 5
        
        URLButton.layer.borderColor = UIColor.gray.cgColor
        URLButton.layer.borderWidth = 1
        URLButton.layer.cornerRadius = 5
    }
    
    private func showConfirmation() {
        self.view.addSubview(copyConfirmationView)
        copyConfirmationView.center = self.view.center
        copyConfirmationView.layer.cornerRadius = 5
        copyConfirmationView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.15, animations: {
            self.copyConfirmationView.transform = CGAffineTransform.identity
        }) { (done) in
            if done {
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
                    self.closeConfirmation()
                })
            }
        }
    }
    
    private func closeConfirmation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.copyConfirmationView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            if done {
                self.copyConfirmationView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func copyCode(_ sender: Any) {
        UIPasteboard.general.string = self.accessCodeButton.titleLabel!.text!
        if UIPasteboard.general.string == self.accessCodeButton.titleLabel!.text! {
            showConfirmation()
        }
    }
    
    @IBAction func shareCode(_ sender: Any) {
        
    }
    
    @IBAction func copyURL(_ sender: Any) {
        UIPasteboard.general.string = self.URLButton.titleLabel!.text!
        if UIPasteboard.general.string == self.URLButton.titleLabel!.text! {
            showConfirmation()
        }
    }
    
    @IBAction func shareURL(_ sender: Any) {
    
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func openMenu(_ sender: Any) {
        MenuHandler.openMenu(vc: self)
    }
    
}
