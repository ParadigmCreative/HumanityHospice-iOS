//
//  ManageFollowersTableViewController.swift
//  HumanityHospice
//
//  Created by App Center on 8/4/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class ManageFollowersTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigaitonController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFollowers()
    }
    
    var followers: [[Follower]] = [[],[]]
    
    struct Follower {
        var name: String
        var id: String
    }
    
    // MARK: - Setup
    func setupNavigaitonController() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
        cancelButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let follower = followers[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = follower.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blocked = 1
        let following = 0
        
        if indexPath.section == 0 {
            let follower = followers[indexPath.section][indexPath.row]
            
            let alert = UIAlertController(title: "Attention!", message: "Would you like to block \(follower.name)? They will no longer be able to see any updates that you post. You can unblock them anytime.", preferredStyle: .alert)
            
            let block = UIAlertAction(title: "Yes, block", style: .destructive) { (alert) in
                DatabaseHandler.blockReader(pid: AppSettings.currentPatient!, rid: follower.id)
                self.followers[blocked].append(follower)
                
                if let index = self.followers[following].index(where: { (f) -> Bool in
                    return follower.id == f.id
                }) {
                    self.followers[following].remove(at: index)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(block)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let follower = followers[indexPath.section][indexPath.row]
            
            let alert = UIAlertController(title: "Attention!", message: "Would you like to unblock \(follower.name)? They will be able to see any updates that you post.", preferredStyle: .alert)
            
            let block = UIAlertAction(title: "Yes, unblock", style: .destructive) { (alert) in
                DatabaseHandler.unblockReader(pid: AppSettings.currentPatient!, rid: follower.id)
                
                self.followers[following].append(follower)
                
                if let index = self.followers[blocked].index(where: { (f) -> Bool in
                    return follower.id == f.id
                }) {
                    self.followers[blocked].remove(at: index)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(block)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Followers"
        } else {
            return "Blocked"
        }
    }

    // MARK: - Get Follower Information
    func getFollowers() {
        DatabaseHandler.getFollowers { (readers) in
            for reader in readers {
                DatabaseHandler.getReaderProfile(rid: reader.key, completion: { (fullName, rid) in
                    let follower = Follower(name: fullName, id: rid)
                    if reader.value == true {
                        self.followers[0].append(follower)
                    } else {
                        self.followers[1].append(follower)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }

}
