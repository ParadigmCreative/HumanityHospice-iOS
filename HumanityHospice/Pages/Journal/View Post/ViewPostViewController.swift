//
//  ViewPostViewController.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit
import DZNEmptyDataSet

class ViewPostViewController: UITableViewController, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMessageView()
        setupEmptyDataSet()
        readjustTableViewForKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listenForComments()
        listenForCommentsRemoved()
        listenForCommentsUpdated()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopListening()
        teardownMessageView()
        stopListeningForKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var post: Post!
    var comments: [Post] = []
    
    // MARK: - Comments Update
    
    var isInitialLoad: Bool = true
    
    func listenForComments() {
        DatabaseHandler.listenForCommentsAdded(postToListenAt: self.post) { (comment) in
            self.comments.append(comment)
            self.tableView.reloadData()
        }
    }
    
    func listenForCommentsRemoved() {
        DatabaseHandler.listenForCommentsRemoved(postToListenAt: self.post) { (id) in
            if let comment = self.comments.index(where: { (comment) -> Bool in
                return comment.id == id
            }) {
                self.comments.remove(at: comment)
                self.tableView.reloadData()
            }
        }
    }
    
    func listenForCommentsUpdated() {
        DatabaseHandler.listenForCommentEdited(postToListenAt: self.post) { (editedComment) in
            if let comment = self.comments.first(where: { (comment) -> Bool in
                return comment.id == editedComment.id
            }) {
                if let index = self.comments.firstIndex(of: comment) {
                    self.comments.remove(at: index)
                    self.comments.insert(editedComment, at: index)
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    func stopListening() {
        DatabaseHandler.stopListeningForComments()
    }
    
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.darkGray
            
            if post.hasImage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imagePostCell", for: indexPath) as! ImagePostTableViewCell
                
                cell.post = self.post
                
                if let img = post.postImage?.getImageFromData() {
                    cell.postImageView.image = img
                    cell.postImageView.layer.cornerRadius = 5
                    cell.postImageView.clipsToBounds = true
                }
                
                cell.posterNameLabel.text = post.posterName
                cell.messageTextView.text = post.message
                cell.dateLabel.text = post.timestamp.toTimeStamp()
                
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textPostCell", for: indexPath) as! TextPostTableViewCell
                
                cell.post = self.post
                
                cell.messageTextView.text = post.message
                cell.posterNameLabel.text = post.posterName
                cell.dateLabel.text = post.timestamp.toTimeStamp()
                
                return cell
            }
        } else {
            
            tableView.separatorStyle = .none
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            
            let comment = comments[indexPath.row]
            
            cell.post = comment
            cell.messageTF.text = comment.message
            cell.timestampLabel.text = comment.timestamp.toTimeStamp()
            cell.posterName.text = comment.posterName
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard comments.count > 0 else { return false }
        let comment = comments[indexPath.row]
        
        if let currentUser = AppSettings.currentFBUser?.displayName {
            if comment.posterName == currentUser {
                if indexPath.section == 1 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let comment = comments[indexPath.row]
//        if editingStyle == .delete {
//            // Delete from firebase
//            DatabaseHandler.removeCommentFromDatabase(post: self.post, comment: comment) {
//                print("Removed comment from Firebase")
//            }
//        }
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let post = self.comments[indexPath.row]
        
        if post.posterUID == AppSettings.currentAppUser!.id {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
                print("Delete")
                self.deleteComment(post: post)

            }
            delete.backgroundColor = UIColor.red
            
            let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
                print("Edit")
                self.messageTF.text = post.message
                self.messageTF.becomeFirstResponder()
                self.isEditingComment = true
                self.commentToEdit = post
            }
            edit.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            
            let config = UISwipeActionsConfiguration(actions: [delete, edit])
            config.performsFirstActionWithFullSwipe = false
            
            return config
        } else {
            return nil
        }
    }
    
    func deleteComment(post: Post) {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            DatabaseHandler.database.child(co.journal.Journals).child(reader.readingFrom).child(self.post.id).child("Comments").child(post.id).setValue(nil)
        } else if let family = AppSettings.currentAppUser as? DatabaseHandler.Family {
            DatabaseHandler.database.child(co.journal.Journals).child(family.patient).child(self.post.id).child("Comments").child(post.id).setValue(nil)
        } else if let patient = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            DatabaseHandler.database.child(co.journal.Journals).child(patient.id).child(self.post.id).child("Comments").child(post.id).setValue(nil)
        }
    }
    
    func editComment(post: Post) {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            DatabaseHandler.database.child(co.journal.Journals).child(reader.readingFrom).child(post.id).updateChildValues(["Comment": post.message])
        } else if let family = AppSettings.currentAppUser as? DatabaseHandler.Family {
            DatabaseHandler.database.child(co.journal.Journals).child(family.patient).child(post.id).updateChildValues(["Comment": post.message])
        } else if let patient = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            DatabaseHandler.database.child(co.journal.Journals).child(patient.id).child(post.id).updateChildValues(["Comment": post.message])
        }
    }
    
    // MARK: - Composing new comment
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let messageTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write a comment..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9999071956, green: 1, blue: 0.999881804, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5115768313, green: 0.5218793154, blue: 0.8382071853, alpha: 1)
        button.layer.cornerRadius = 5
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        return button
    }()
    
    var nav: UINavigationController?
    private func setupMessageView() {
        self.navigationController!.view.addSubview(messageInputContainerView)
        nav = self.navigationController
        messageInputContainerView.snp.makeConstraints { (make) in
            print(UIDevice.modelName)
            if UIDevice.modelName.isiPhoneX() {
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-22)
            } else {
                make.left.right.bottom.equalToSuperview()
            }
            make.height.equalTo(48)
            self.setupInputView()
        }
    }
    
    private func teardownMessageView() {
        self.messageInputContainerView.removeFromSuperview()
    }
    
    private func setupInputView() {
        
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        self.messageInputContainerView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        self.messageInputContainerView.addSubview(messageTF)
        messageTF.snp.makeConstraints { (make) in
            make.left.equalTo(16)
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
                            make.left.right.equalToSuperview()
                            make.bottom.equalToSuperview().offset(-22)
                            make.height.equalTo(48)
                            self.adjustForKeyboard(notification: notification)
                        }
                    } else {
                        self.messageInputContainerView.snp.remakeConstraints { (make) in
                            make.left.right.equalToSuperview()
                            make.height.equalTo(48)
                            make.bottom.equalToSuperview().offset(-keyboardFrame.height)
                            self.adjustForKeyboard(notification: notification)
                        }
                    }
                })
            }
        }
    }
    
    func stopListeningForKeyboard() {
        if let commentObs = self.commentObserver {
            NotificationCenter.default.removeObserver(commentObs)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    var keyboardInfo: [AnyHashable: Any]?
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        keyboardInfo = userInfo
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            let height = keyboardViewEndFrame.height + self.messageInputContainerView.frame.height
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            
            let count = comments.count
//            tableView.scrollToRow(at: IndexPath(row: count - 1, section: 1), at: .bottom, animated: true)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func commentWasPosted() {
        if let info = keyboardInfo {
            NotificationCenter.default.post(name: .commentWasPosted, object: nil, userInfo: info)
        }
    }
    
    var commentObserver: NSObjectProtocol?
    func readjustTableViewForKeyboard() {
        commentObserver = NotificationCenter.default.addObserver(forName: .commentWasPosted, object: nil, queue: .main) { (notification) in
            self.adjustForKeyboard(notification: notification)
        }
    }
    
    var isEditingComment = false
    var commentToEdit: Post?
    @objc func postComment() {
        //check that the field is not empty
        guard let commentText = messageTF.text else { return }
        guard commentText.count > 0 else {
            // show error
            return
        }
        
        guard let posterID = AppSettings.currentAppUser?.id else { return }
        guard let posterName = AppSettings.currentAppUser?.fullName() else { return }
        
        if isEditingComment {
            if let comment = commentToEdit {
                let ref = DatabaseHandler.database.child("Journals").child(AppSettings.currentPatient!)
                ref.child(self.post.id).child("Comments").child(comment.id).updateChildValues(["Comment": commentText])
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.commentWasPosted()
                    self.messageTF.text = ""
                    self.isEditingComment = false
                }
            }
        } else {
            //if not, then create post object
            let data: [String: Any] = [co.journal.comment.Timestamp: Date().timeIntervalSince1970,
                                       co.journal.comment.PosterName: posterName,
                                       co.journal.comment.PosterUID: posterID,
                                       co.journal.comment.Comment: commentText]
            
            // post to db
            let postID = self.post.id
            DatabaseHandler.postCommentToDatabase(postID: postID, data: data, completion: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.commentWasPosted()
                    self.messageTF.text = ""
                }
            })
        }
    }
    
    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Empty Data Set
    func setupEmptyDataSet() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
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

extension Post {
    func getListArray() -> [Post]? {
        if self.comments.count > 0 {
            let comments = Array(self.comments)
            let sorted = comments.sorted { (p1, p2) -> Bool in
                return p1.timestamp < p2.timestamp
            }
            return sorted
        } else {
            return nil
        }
    }
}
