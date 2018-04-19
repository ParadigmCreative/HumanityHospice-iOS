//
//  MenuHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit

protocol MenuHandlerDelegate {
    func userDidPressMenuButton()
}

class MenuView: UIView, UITableViewDataSource, UITableViewDelegate, MenuHandlerDelegate {
    
    var isMenuShowing: Bool?
    
    // MARK: - TableView
    @IBOutlet weak var listingTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    var items = ["My Journal", "Encouragement Board", "My Photo Album", "Create Family Account", "Invite People", "Sigh Out", "About Humanity Hospice"]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - MenuHandler Delegate
    func userDidPressMenuButton() {
        
    }
    
    // Static Functions
    
}
