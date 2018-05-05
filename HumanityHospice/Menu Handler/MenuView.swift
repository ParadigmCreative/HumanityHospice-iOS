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
    
    
    // MARK: - TableView
    var items = ["My Journal", "Encouragement Board", "My Photo Album", "Create Family Account", "Invite People", "Sign Out", "About Humanity Hospice"]
    @IBOutlet weak var listingTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuTableViewCell(style: .default, reuseIdentifier: "cell")
        
        // TODO: add icon for each cell
        
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont().setFont()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        
        if selected == items[0] {
            // Journal
            MenuHandler.tabbar?.selectedIndex = 0
            MenuHandler.closeMenu()
        } else if selected == items[1] {
            // Board
            MenuHandler.tabbar?.selectedIndex = 1
            MenuHandler.closeMenu()
        } else if selected == items[2] {
            // Album
            MenuHandler.tabbar?.selectedIndex = 2
            MenuHandler.closeMenu()
        } else if selected == items[3] {
            // Create Fam Acct
            MenuHandler.tabbar?.selectedIndex = 3
            MenuHandler.closeMenu()
        } else if selected == items[4] {
            // Invite
            MenuHandler.tabbar?.selectedIndex = 4
            MenuHandler.closeMenu()
        } else if selected == items[5] {
            // Sign Out
            Utilities.showActivityIndicator(view: self)
            handlingController?.beginSignOutProcess()
        } else if selected == items[6] {
            // About
            MenuHandler.tabbar!.selectedIndex = 5
            MenuHandler.closeMenu()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func setupTable() {
        self.listingTableView.delegate = self
        self.listingTableView.dataSource = self
        
        self.listingTableView.separatorStyle = .none
        self.listingTableView.tableFooterView = UIView()
        self.listingTableView.isScrollEnabled = false
        self.listingTableView.emptyDataSetSource = self
        self.listingTableView.emptyDataSetDelegate = self
    }
    
    func setupHeader() {
        guard let email = AppSettings.currentFBUser?.email else { return }
        emailLabel.text = email
        emailLabel.font = UIFont().setFont()
        
        guard let first = AppSettings.currentAppUser?.firstName else { return }
        guard let last  = AppSettings.currentAppUser?.lastName else { return }

        nameLabel.text = "\(first) \(last)"
        nameLabel.font = UIFont().setFont()
    }
    
    func setupProfilePicture() {
        
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
