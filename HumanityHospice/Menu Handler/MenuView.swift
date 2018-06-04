//
//  MenuHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import ImagePicker

protocol MenuHandlerDelegate {
    func setBaseView(view: UIView)
    func setHandingController(vc: UIViewController)
}

class MenuView: UIView, UITableViewDataSource, UITableViewDelegate, MenuHandlerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    
    var isMenuShowing: Bool?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var mainAreaView: UIView!
    @IBOutlet weak var exitAreaView: UIView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    var imagePicker = ImagePickerController()
    
    // MARK: - TableView
    var items = ["My Journal", "Encouragement Board", "My Photo Album", "Create Family Account", "Invite People", "Sign Out", "About Humanity Hospice"]
    var itemsIcons = [#imageLiteral(resourceName: "journal"), #imageLiteral(resourceName: "Bubbles - simple-line-icons"), #imageLiteral(resourceName: "Picture - simple-line-icons"), #imageLiteral(resourceName: "User - simple-line-icons"), #imageLiteral(resourceName: "Plus - simple-line-icons"), #imageLiteral(resourceName: "Login - simple-line-icons"), #imageLiteral(resourceName: "Info - simple-line-icons")]
    
    var readerItems = ["Journal", "Encouragement Board", "Photo Album", "Sign Out", "About Humanity Hospice"]
    var readerIcons = [#imageLiteral(resourceName: "journal"), #imageLiteral(resourceName: "Bubbles - simple-line-icons"), #imageLiteral(resourceName: "Picture - simple-line-icons"), #imageLiteral(resourceName: "Login - simple-line-icons"), #imageLiteral(resourceName: "Info - simple-line-icons")]
    
    
    var menuItems: [String] = []
    var menuIcons: [UIImage] = []
    
    @IBOutlet weak var listingTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuTableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.imageView?.contentMode = .scaleAspectFit
        cell.selectionStyle = .none
        cell.imageView?.image = menuIcons[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = menuItems[indexPath.row]
        
        if selected == "My Journal" || selected == "Journal" {
            // Journal
            MenuHandler.tabbar?.selectedIndex = 0
            MenuHandler.closeMenu()
        } else if selected == "Encouragement Board" {
            // Board
            MenuHandler.tabbar?.selectedIndex = 1
            MenuHandler.closeMenu()
        } else if selected == "My Photo Album" || selected == "Photo Album" {
            // Album
            MenuHandler.tabbar?.selectedIndex = 2
            MenuHandler.closeMenu()
        } else if selected == "Create Family Account" {
            // Create Fam Acct
            MenuHandler.tabbar?.selectedIndex = 3
            MenuHandler.closeMenu()
        } else if selected == "Invite People" {
            // Invite
            MenuHandler.tabbar?.selectedIndex = 4
            MenuHandler.closeMenu()
        } else if selected == "Sign Out" {
            // Sign Out
            Utilities.showActivityIndicator(view: self)
            AppSettings.clearAppSettings()
            handlingController?.beginSignOutProcess()
        } else if selected == "About Humanity Hospice" {
            // About
            MenuHandler.tabbar!.selectedIndex = 5
            MenuHandler.closeMenu()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    // MARK: - Setup
    
    func setupTable() {
        setupMenuItems()
        
        self.listingTableView.delegate = self
        self.listingTableView.dataSource = self
        
        self.listingTableView.separatorStyle = .none
        self.listingTableView.tableFooterView = UIView()
        self.listingTableView.isScrollEnabled = false
        self.listingTableView.emptyDataSetSource = self
        self.listingTableView.emptyDataSetDelegate = self
        
    }
    
    func setupHeader() {
        checkForProfilePicture()

        guard let email = AppSettings.currentFBUser?.email else { return }
        emailLabel.text = email
        
        guard let first = AppSettings.currentAppUser?.firstName else { return }
        guard let last  = AppSettings.currentAppUser?.lastName else { return }

        nameLabel.text = "\(first) \(last)"
    }
    
    func setupMenuItems() {
        if let type = AppSettings.userType {
            if type == .Patient || type == .Family {
                self.menuItems = items
                self.menuIcons = itemsIcons
            } else {
                self.menuItems = readerItems
                self.menuIcons = readerIcons
                if checkForMultiplePatients() {
                    menuItems.append("Switch Patients")
                    menuIcons.append(#imageLiteral(resourceName: "Switch Users"))
                }
            }
        }
    }
    
    func checkForMultiplePatients() -> Bool {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            let patients = reader.patients
            if patients.count > 1 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func checkForProfilePicture() {
        if let img = ProfilePickerHandler.chosenPhoto {
            setupProfilePicture(img: img)
        } else {
            DatabaseHandler.getProfilePicture { (done) in
                if done {
                    if let img = ProfilePickerHandler.chosenPhoto {
                        self.setupProfilePicture(img: img)
                    }
                }
            }
        }
    }
    
    func setupProfilePicture(img: UIImage) {
        logoImageView.image = img
        logoImageView.setupProfilePicture()
        editProfileImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
        if let vc = handlingController {
            ProfilePickerHandler.open(vc: vc)
        }
    }
    
    
    
    
    // MARK: - MenuHandler Delegate
    var baseView: UIView?
    func setBaseView(view: UIView) {
        baseView = view
    }
    
    var handlingController: UIViewController?
    func setHandingController(vc: UIViewController) {
        self.handlingController = vc
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == exitAreaView {
                MenuHandler.closeMenu()
            }
        }
    }
    
    
}
