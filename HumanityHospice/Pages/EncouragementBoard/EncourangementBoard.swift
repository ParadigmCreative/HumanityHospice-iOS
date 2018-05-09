//
//  EncourangementBoard.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class EncourangementBoard: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenuHandler.staticMenu?.setHandingController(vc: self)
        setupEmptyDataSet()
        getPosts()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    var ebposts: [EBPost] = []
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ebposts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EBCell", for: indexPath) as! EncouragementBoardTableViewCell
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: - Button Actions
    
    // newPostButton
    @IBAction  func newPost(_ sender: Any) {
        performSegue(withIdentifier: "showNewPostVC", sender: self)
    }
    
    func getPosts() {
        DatabaseHandler.getEBPosts { (posts) in
            if posts.count > 0 {
                self.ebposts = posts
            }
        }
    }
    
    // MARK: - Empty Dataset
    
    func setupEmptyDataSet() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "No posts yet!"
        let attStr = NSAttributedString(string: title)
        return attStr
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let desc = "Share your invite code to allow people to post in your Encouragement Board!"
        let attr = NSAttributedString(string: desc)
        return attr
    }

}
