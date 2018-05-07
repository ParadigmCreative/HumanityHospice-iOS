//
//  JournalTableViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class JournalTableViewController: UITableViewController {

    
    var menuDelegate: MenuHandlerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        MenuHandler.initialize(vc: self)
        menuDelegate = MenuHandler.staticMenu
        setup()
        getPosts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - General Setup
    func setup() {
        self.tabBarController?.tabBar.isHidden = true
        
        if let type = AppSettings.userType {
            if type != .Patient {
                self.newPostButton.isEnabled = false
                self.navigationItem.rightBarButtonItem = nil
            }
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "postWithImage", for: indexPath) as! PostWithImageTableViewCell
            
            cell.nameLabel.text = post.poster
            cell.message.text = post.message
            cell.postPhoto.image = post.postImage
            
            cell.message.layer.cornerRadius = 5
            cell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            cell.userImage.image = #imageLiteral(resourceName: "Logo")
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as! JournalTableViewCell
            
            cell.nameLabel.text = post.poster
            cell.message.text = post.message
            
            cell.message.layer.cornerRadius = 5
            cell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            cell.userImage.image = #imageLiteral(resourceName: "Logo")
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Get Data
    var posts: [Post] = []
    private func getPosts() {
        DatabaseHandler.getPostsFromDB { (posts) in
            
            // if patient, add first welcome post
            
            var sortedPosts: [Post] = []
            for post in posts {
                if post.comments != nil {
                    post.comments!.sort(by: { (p1, p2) -> Bool in
                        return p1.timestamp > p2.timestamp
                    })
                }
            }
            
            sortedPosts = posts.sorted(by: { (p1, p2) -> Bool in
                return p1.timestamp > p2.timestamp
            })
            
            self.posts = sortedPosts
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Write New Post
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBAction func newPost(_ sender: Any) {
        self.performSegue(withIdentifier: "showNewPost", sender: self)
    }
    
 

  
    // MARK: - Navigation
    var menuIsShowing: Bool = false
    @IBAction func toggleMenu(_ sender: Any) {
        
        MenuHandler.openMenu(vc: self)
        
    }

    
}












