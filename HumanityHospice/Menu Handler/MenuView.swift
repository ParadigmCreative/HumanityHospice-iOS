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
}

class MenuView: UIView, UITableViewDataSource, UITableViewDelegate, MenuHandlerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var isMenuShowing: Bool?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var mainAreaView: UIView!
    @IBOutlet weak var exitAreaView: UIView!
    
    
    // MARK: - TableView
    var items = ["My Journal", "Encouragement Board", "My Photo Album", "Create Family Account", "Invite People", "Sign Out", "About Humanity Hospice"]
    @IBOutlet weak var listingTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    // MARK: - MenuHandler Delegate
    var baseView: UIView?
    func setBaseView(view: UIView) {
        baseView = view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == exitAreaView {
                MenuHandler.closeMenu()
            }
        }
    }
    
    
}
