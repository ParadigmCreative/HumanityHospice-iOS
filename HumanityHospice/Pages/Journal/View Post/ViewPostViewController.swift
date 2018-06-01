//
//  ViewPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class ViewPostViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        postDelegate?.didRecievePost(post: self.post)
        if let comments = post.getListArray() {
            commentsDelegate?.didRecieveComments(comments: comments)
        } else {
            commentsDelegate?.didRecieveComments(comments: [])
        }
        
        
        setupMessageView()
        setupContainerViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listenForComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopListening()
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
    
    // MARK: - Comments Update
    
    var isInitialLoad: Bool = true
    
    func listenForComments() {
        DatabaseHandler.listenForCommentsAdded(post: self.post, completion: {
            let comments = Array(self.post.comments)
            self.commentsDelegate?.didRecieveComments(comments: comments)
        })
    }
    
    func stopListening() {
        DatabaseHandler.stopListeningForComments()
    }
    
    // MARK: - Views
    
    @IBOutlet weak var postContainerView: UIView!
    @IBOutlet weak var comentsContainerView: UIView!
    
    private func setupContainerViews() {
        let total = self.view.frame.height
        let postHeight = self.postContainerView.frame.height
        let commentHeight = total - postHeight
        
        comentsContainerView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(postContainerView.snp.bottom)
        }
        
    }
    
    
    
    // MARK: - Composing new comment
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let messageTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write a comment..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5098039216, green: 0.5215686275, blue: 0.8392156863, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        return button
    }()
    
    private func setupMessageView() {
        self.view.addSubview(messageInputContainerView)
        messageInputContainerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
            self.setupInputView()
        }
    }
    
    private func setupInputView() {
        
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        self.messageInputContainerView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        self.messageInputContainerView.addSubview(messageTF)
        messageTF.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(sendButton.snp.left)
        }
        
        self.messageInputContainerView.addSubview(topBorder)
        topBorder.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardBecomeActive(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardBecomeActive(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        setupGestureRecognizer()
    }
    

    // MARK: - TextField
    @objc func handleKeyboardBecomeActive(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                // (x,y,w,h)
                
                let isKeyboardIsShowing = notification.name == .UIKeyboardWillHide
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    if isKeyboardIsShowing {
                        self.messageInputContainerView.snp.remakeConstraints { (make) in
                            make.left.right.bottom.equalToSuperview()
                            make.height.equalTo(48)
                            self.setupInputView()
                        }
                    } else {
                        self.messageInputContainerView.snp.remakeConstraints { (make) in
                            make.left.right.equalToSuperview()
                            make.height.equalTo(48)
                            make.bottom.equalToSuperview().offset(-keyboardFrame.height)
                        }
                    }
                })
            }
        }
    }
    
    @objc private func postComment() {
        //check that the field is not empty
        guard let commentText = messageTF.text else { return }
        guard commentText.count > 0 else {
            // show error
            return
        }
        
        guard let posterID = AppSettings.currentAppUser?.id else { return }
        guard let posterName = AppSettings.currentAppUser?.fullName() else { return }
        var profilePictureURl: String?
        if let profileURL = AppSettings.currentFBUser?.photoURL {
            profilePictureURl = profileURL.absoluteString
        }
        
        
        //if not, then create post object
        let data: [String: Any] = ["timestamp": Date().timeIntervalSince1970,
                                   "poster": posterName,
                                   "posterID": posterID,
                                   "posterProfilePictureURL": profilePictureURl,
                                   "post": commentText]
        
        // post to db
        let postID = self.post.id
        DatabaseHandler.postCommentToDatabase(postID: postID, data: data, completion: {
            self.view.endEditing(true)
            commentsDelegate?.reloadTable()
            self.messageTF.text = ""
        })
        
        // refresh commments tableview
    }
    
    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
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
    func reloadTable()
    func newCommentAdded()
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
