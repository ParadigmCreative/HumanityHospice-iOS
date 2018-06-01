//
//  CommentsViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentsViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var commentsTableView: UITableView!
    
    var comments: [Post]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        setupEmptyDataSet()

        // Do any additional setup after loading the view.
    }
    
    func didRecieveComments(comments: [Post]) {
        self.comments = comments
        DispatchQueue.main.async {
            self.commentsTableView.reloadData()
        }
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.commentsTableView.reloadData()
        }
    }
    
    func newCommentAdded() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = self.comments {
            return comments.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentPost", for: indexPath) as! CommentTableViewCell
        
        if let comment = self.comments?[indexPath.row] {
            cell.post = comment
            cell.messageTF.text = comment.message
            cell.timestampLabel.text = comment.timestamp.toTimeStamp()
            cell.posterName.text = comment.poster
        }
        
        return cell
    }
    
    func setupEmptyDataSet() {
        self.commentsTableView.emptyDataSetSource = self
        self.commentsTableView.emptyDataSetDelegate = self
        
        self.commentsTableView.tableFooterView = UIView()
        
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "Nothing to see here..."
        let attStr = NSAttributedString(string: title)
        return attStr
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let desc = "Be the first to comment!"
        let attr = NSAttributedString(string: desc)
        return attr
    }
    

}
