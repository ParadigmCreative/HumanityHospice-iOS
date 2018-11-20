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
        
        self.title = "Encouragement Board"
        MenuHandler.staticMenu?.setHandingController(vc: self)
        setupEmptyDataSet()
        
        if let type = AppSettings.userType {
            if type == .Patient || type == .Family {
                self.newPostButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPostsAndListenForPostAdded()
        listenForPostsEdited()
        listenForPostsDeleted()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ebpost", for: indexPath) as! EncouragementBoardTableViewCell
        
        let post = ebposts[indexPath.row]
        
        cell.post = post
        
        cell.messageTF.text = post.message
        cell.nameLabel.text = post.posterName
        cell.messageTF.layer.cornerRadius = 5
        cell.messageTF.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
        cell.timestampLabel.text = post.timestamp.toTimeStamp()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let post = self.ebposts[indexPath.row]
        
        if post.posterUID == AppSettings.currentAppUser!.id {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
                print("Delete")
                self.deletePost(post: post)
            }
            delete.backgroundColor = UIColor.red
            
            let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
                print("Edit")
                self.performSegue(withIdentifier: "showNewPostVC", sender: post)
            }
            edit.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            
            let config = UISwipeActionsConfiguration(actions: [delete, edit])
            config.performsFirstActionWithFullSwipe = false
            
            return config
        } else {
            return nil
        }
        
    }
    
    func deletePost(post: EBPost) {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            DatabaseHandler.database.child(co.encouragementBoard.EncouragementBoards).child(reader.readingFrom).child(post.id).setValue(nil)
        }
    }
    
    func editPost(post: EBPost) {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            let postRef = DatabaseHandler.database.child(co.encouragementBoard.EncouragementBoards).child(reader.readingFrom)
            postRef.updateChildValues(["Message": post.message])
        }
    }
    
    //MARK: - Button Actions
    
    // newPostButton
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBAction  func newPost(_ sender: Any) {
        performSegue(withIdentifier: "showNewPostVC", sender: self)
    }
    
    func getPostsAndListenForPostAdded() {
        DatabaseHandler.listenForEBPostAdded(completion: { (posts) in
            if posts.count > 0 {
                
                let posts = RealmHandler.getEBPostList()
                
                let postsToSet = self.setPosts(posts: posts)
                
                self.ebposts = postsToSet
                self.tableView.reloadData()
            }
        })
    }
    
    func listenForPostsEdited() {
        DatabaseHandler.listenForEBPostChanged { (posts) in
            let posts = RealmHandler.getEBPostList()
            
            let toSet = self.setPosts(posts: posts)
            
            self.ebposts = toSet
            self.tableView.reloadData()
        }
    }
    
    func listenForPostsDeleted() {
        DatabaseHandler.listenForEBPostDeleted {
            let posts = RealmHandler.getEBPostList()
            
            let toSet = self.setPosts(posts: posts)
            
            self.ebposts = toSet
            self.tableView.reloadData()
        }
    }

    
    func sortPosts(posts: [EBPost]) -> [EBPost] {
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        return sorted
    }
    
    func setPosts(posts: [EBPost]) -> [EBPost] {
        switch AppSettings.userType! {
        case .Patient:
            // Get everything
            
            return posts
            
        case .Family, .Reader, .Staff:
            // Get only the ones that match the ID
            
            if let uid = AppSettings.currentFBUser?.uid {
                let filtered = posts.filter { (post) -> Bool in
                    return post.posterUID == uid
                }
                
                let sorted = sortPosts(posts: filtered)
                return sorted
            } else {
                return []
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
    
    @IBAction func toggleMenu(_ sender: Any) {
        
        MenuHandler.openMenu(vc: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewPostVC" {
            if let post = sender as? EBPost {
                if let vc = segue.destination as? NewEBPostViewController {
                    vc.EBPostToEdit = post
                }
            }
        }
    }

}
