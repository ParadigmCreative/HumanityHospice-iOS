//
//  PostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import RealmSwift

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostViewDelegate {

    @IBOutlet weak var postTableView: UITableView!
    
    var post: Post!
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        
        let foot = UIView()
        postTableView.tableFooterView = foot
        
        let height = postTableView.frame.height
        print(height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didRecievePost(post: Post) {
        self.post = post
        DispatchQueue.main.async {
            self.postTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagePost", for: indexPath) as! ImagePostTableViewCell
            
            cell.post = self.post
            
            if let img = post.postImage?.getImageFromData() {
                cell.postImageView.image = img
                cell.postImageView.layer.cornerRadius = 5
                cell.postImageView.clipsToBounds = true
            }
            
            cell.posterNameLabel.text = post.poster
            cell.messageTextView.text = post.message
            cell.dateLabel.text = post.timestamp.toTimeStamp()
            
            
            let height = postTableView.frame.height
            print(height)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textPost", for: indexPath) as! TextPostTableViewCell
            
            cell.post = self.post
            
            cell.messageTextView.text = post.message
            cell.posterNameLabel.text = post.poster
            cell.dateLabel.text = post.timestamp.toTimeStamp()
            
            return cell
            
        }
    }
    
    

}
