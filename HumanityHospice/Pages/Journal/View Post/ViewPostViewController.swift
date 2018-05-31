//
//  ViewPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class ViewPostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        postDelegate?.didRecievePost(post: self.post)
        if let comments = post.getListArray() {
            commentsDelegate?.didRecieveComments(comments: comments)
        } else {
            commentsDelegate?.didRecieveComments(comments: [])
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var post: Post!
    
    var postDelegate: PostViewDelegate?
    var commentsDelegate: CommentsViewDelegate?
    
    var postView: PostViewController? {
        didSet {
            postDelegate = postView
        }
    }
    var commentsView: CommentsViewController? {
        didSet {
            commentsDelegate = commentsView
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PostViewController {
            postView = vc
        } else if let vc = segue.destination as? CommentsViewController {
            commentsView = vc
        }
    }
    
}

protocol PostViewDelegate {
    func didRecievePost(post: Post)
}

protocol CommentsViewDelegate {
    func didRecieveComments(comments: [Post])
}

extension Post {
    func getListArray() -> [Post]? {
        if self.comments.count > 0 {
            let comments = Array(self.comments)
            return comments
        } else {
            return nil
        }
    }
}

