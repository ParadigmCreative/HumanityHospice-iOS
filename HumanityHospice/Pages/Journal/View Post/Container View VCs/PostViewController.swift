//
//  PostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import RealmSwift

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var postTableView: UITableView!
    
    var post: Post!
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagePost", for: indexPath) as! ImagePostTableViewCell
            
            if let img = post.postImage?.getImageFromData() {
                cell.postImageView.image = img
            }
            
            cell.posterNameLabel.text = post.poster
            cell.messageTextView.text = post.message
//            cell.profilePictureView.image = post.
            
            
        } else {
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
