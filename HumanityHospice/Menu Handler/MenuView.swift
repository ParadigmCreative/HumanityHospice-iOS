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
    @IBOutlet weak var callNurseButton: UIButton!
    @IBAction func callNurse(_ sender: UIButton) {
        
        VideoCallDatabaseHandler.requestCallToNurse { (vc, error) in
            guard error == nil else {
                var alert: UIAlertController
                
                switch error! {
                case .NoTokenForNurse:
                    alert = UIAlertController(title: "Hmmm...",
                                              message: "We can't contact your nurse right now. Please try again later",
                                              preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                case .NoNurseOnCallForTeam:
                    alert = UIAlertController(title: "No Nurses Available",
                                              message: "No nurses are on call right now. If this is an emergency, please dial 911.",
                                              preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                
                self.handlingController?.present(alert, animated: true, completion: nil)
                
                return
            }
            
            MenuHandler.closeMenu()
            guard let vc = vc else { return }
            self.handlingController?.present(vc, animated: true, completion: nil)
            
        }
        
    }
    @IBOutlet weak var versionLabel: UILabel!
    
    private func facetime(phoneNumber:String) {
        if let facetimeURL: URL = URL(string: "facetime://\(phoneNumber)") {
            let application: UIApplication = UIApplication.shared
            if application.canOpenURL(facetimeURL as URL) {
                application.open(facetimeURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func showNurseUnavailableAlert(name: String, completion: @escaping ()->()) {
        let alert = UIAlertController(title: "Attention!", message: "Your assigned nurse isn't on call right now. Another nurse, \(name), is available. Would you like to call them?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No, cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, call \(name)", style: .default, handler: { (action) in
            completion()
        }))
        
        self.handlingController?.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - TableView
    var items = ["My Journal", "Encouragement Board", "My Photo Album", "Create Family Account", "Invite People", "Manage Followers", "About Humanity Hospice", "Sign Out"]
    var itemsIcons = [#imageLiteral(resourceName: "journal"), #imageLiteral(resourceName: "Bubbles - simple-line-icons"), #imageLiteral(resourceName: "Picture - simple-line-icons"), #imageLiteral(resourceName: "User - simple-line-icons"), #imageLiteral(resourceName: "Plus - simple-line-icons"), #imageLiteral(resourceName: "Switch Users"), #imageLiteral(resourceName: "Info - simple-line-icons"), #imageLiteral(resourceName: "Login - simple-line-icons")]
    
    var readerItems = ["Journal", "Encouragement Board", "Photo Album", "About Humanity Hospice", "Sign Out"]
    var readerIcons = [#imageLiteral(resourceName: "journal"), #imageLiteral(resourceName: "Bubbles - simple-line-icons"), #imageLiteral(resourceName: "Picture - simple-line-icons"), #imageLiteral(resourceName: "Info - simple-line-icons"), #imageLiteral(resourceName: "Login - simple-line-icons")]
    
    
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
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        
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
        } else if selected == "Manage Followers" {
            MenuHandler.closeMenu()
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ManageFollowersVC") as? ManageFollowersTableViewController {
                let nav = UINavigationController(rootViewController: vc)
                let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                nav.navigationBar.titleTextAttributes = textAttributes
                nav.navigationBar.barTintColor = #colorLiteral(red: 0.3529411765, green: 0.231372549, blue: 0.6235294118, alpha: 1)
                handlingController?.present(nav, animated: true, completion: nil)
            }
        } else if selected == "About Humanity Hospice" {
            // About
            MenuHandler.tabbar!.selectedIndex = 5
            MenuHandler.closeMenu()
        } else if selected == "Switch Patients" {
            // Switch Patients
            MenuHandler.closeMenu()
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ChangePatientVC") as? SwitchPatientTableViewController {
                let nav = UINavigationController(rootViewController: vc)
                let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
                nav.navigationBar.titleTextAttributes = textAttributes
                nav.navigationBar.barTintColor = #colorLiteral(red: 0.3529411765, green: 0.231372549, blue: 0.6235294118, alpha: 1)
                handlingController?.present(nav, animated: true, completion: nil)
            }
        } else if selected == "Sign Out" {
            // Sign Out
            MenuHandler.closeMenu()
            Utilities.showActivityIndicator(view: self)
            AppSettings.clearAppSettings()
            handlingController?.beginSignOutProcess()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var total = tableView.frame.height
        let numberOfItems = self.menuItems.count
        
        total -= 75
        
        let height = total / CGFloat(numberOfItems)
        return height
    }
    
    // MARK: - Setup
    
    func setupTable() {
        setupMenuItems()
        
        self.listingTableView.delegate = self
        self.listingTableView.dataSource = self
        self.listingTableView.showsVerticalScrollIndicator = true
        self.listingTableView.separatorStyle = .none
        self.listingTableView.tableFooterView = UIView()
        self.listingTableView.isScrollEnabled = true
        self.listingTableView.emptyDataSetSource = self
        self.listingTableView.emptyDataSetDelegate = self
        
    }
    
    func setupHeader() {
        setupBuildNumber()
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
                    menuItems.insert("Switch Patients", at: 4)
                    menuIcons.insert(#imageLiteral(resourceName: "Switch Users"), at: 4)
                }
                self.callNurseButton.isHidden = true
                self.callNurseButton.isEnabled = false
            }
        }
    }
    
    func setupBuildNumber() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        let str = "\(version) - \(build)"
        self.versionLabel.text = str
    }
    
    func checkForMultiplePatients() -> Bool {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            let patients = reader.patients
            if patients.count > 0 {
                return true
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func checkForProfilePicture() {
        if let img = ProfilePickerHandler.chosenPhoto {
            setupProfilePicture(img: img)
        } else {
            DatabaseHandler.checkForProfilePicture(for: AppSettings.currentAppUser!.id) { (urlString) in
                if let urlString = urlString {
                    if let url = URL(string: urlString) {
                        DatabaseHandler.getProfilePicture(URL: url, completion: { (image) in
                            if let img = image {
                                self.setupProfilePicture(img: img)
                            }
                        })
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

