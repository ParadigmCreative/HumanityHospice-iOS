//
//  JournalTableViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class JournalTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, ProfilePictureDelegate, CommentsDelegate {

    
    var menuDelegate: MenuHandlerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        MenuHandler.initialize(vc: self)
        menuDelegate = MenuHandler.staticMenu
        setup()
        ProfilePickerHandler.profilePictureDelegate = self
        
    }
    
    func userDidSelectPhoto(image: UIImage) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // MARK: - General Setup
    func setup() {
        resetPosts()
        listenForAddition()
        listenForRemoval()
        self.tabBarController?.tabBar.isHidden = true
        setupEmptyDataSet()
        if let type = AppSettings.userType {
            switch type {
            case .Reader, .Staff:
                self.newPostButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil
            default:
                print(type)
            }
        }
    }
    
    func resetPosts() {
        RealmHandler.resetJournalPosts()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if post.hasImage {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "postWithImage", for: indexPath) as! PostWithImageTableViewCell
            imageCell.layoutSubviews()
            
            let indicator = Utilities.createActivityIndicator(view: imageCell)
            imageCell.indicator = indicator
            imageCell.post = post
            imageCell.commentDelegate = self
            
            imageCell.nameLabel.text = post.poster
            imageCell.message.text = post.message
            imageCell.postPhoto.clipsToBounds = true
            
            imageCell.message.layer.cornerRadius = 5
            imageCell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            imageCell.postPhoto.layer.cornerRadius = 5
            if let img = ProfilePickerHandler.chosenPhoto {
                imageCell.userImage.image = img
                imageCell.userImage.setupSecondaryProfilePicture()
            } else {
                imageCell.userImage.image = #imageLiteral(resourceName: "Logo")
            }
            
            let count = post.comments.count
            if count > 0 {
                imageCell.commentsButton.setTitle("Comments (\(count))   ", for: .normal)
            } else {
                imageCell.commentsButton.setTitle("Comments (0)   ", for: .normal)
            }
        
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as! JournalTableViewCell
            cell.layoutSubviews()
            
            cell.post = post
            cell.commentDelegate = self
            
            cell.nameLabel.text = post.poster
            cell.message.text = post.message
            
            cell.message.layer.cornerRadius = 5
            cell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            if let img = ProfilePickerHandler.chosenPhoto {
                cell.userImage.image = img
                cell.userImage.setupSecondaryProfilePicture()
            } else {
                cell.userImage.image = #imageLiteral(resourceName: "Logo")
            }
            
            let count = post.comments.count
            if count > 0 {
                cell.commentsButton.setTitle("Comments (\(count))   ", for: .normal)
            } else {
                cell.commentsButton.setTitle("Comments (0)   ", for: .normal)
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if AppSettings.userType == DatabaseHandler.UserType.Patient {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let post = self.posts[indexPath.row]
            DatabaseHandler.removeFromDatabase(post: post) { (done) in
                if done {
                    print("Deleted From Firebase")
                }
            }
        }
    }
    
    func userDidSelectPostForComments(post: Post) {
        // load page with post
    }
    
    // MARK: - Get Data
    var posts: [Post] = []
    func getPosts() {
        DatabaseHandler.getPostsFromDB { (posts) in
            if let posts = posts {
                self.posts = posts
            }
            self.tableView.reloadData()
        }
    }
    
    func listenForRemoval() {
        DatabaseHandler.listenForPostRemoved {
            let posts = RealmHandler.getPostList()
            print("After:", posts.count)
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    func listenForAddition() {
        DatabaseHandler.listenForPostAdded {
            let posts = RealmHandler.getPostList()
            print("After:", posts.count)
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Write New Post
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBAction func newPost(_ sender: Any) {
        self.performSegue(withIdentifier: "showNewPost", sender: self)
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
        let desc = "Click the 'compose' button at the top to write your first Journal entry!"
        let attr = NSAttributedString(string: desc)
        return attr
    }

  
    // MARK: - Navigation
    var menuIsShowing: Bool = false
    @IBAction func toggleMenu(_ sender: Any) {
        
        MenuHandler.openMenu(vc: self)
        
    }

    
}












