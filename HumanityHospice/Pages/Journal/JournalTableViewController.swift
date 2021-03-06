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
    var loadingDelegate: LoadingViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        master()
        listenForNewUserSelection()
    }
    
    func userDidSelectPhoto(image: UIImage) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func listenForNewUserSelection() {
        NotificationCenter.default.addObserver(forName: .userSelectedNewPatient, object: nil, queue: .main) { (notification) in
            self.posts = []
            self.tableView.reloadData()
            self.master()
        }
    }
    
    func master() {
        setupLoadingView()
        
        MenuHandler.initialize(vc: self)
        menuDelegate = MenuHandler.staticMenu
        setup()
        ProfilePickerHandler.profilePictureDelegate = self
    }
    
    func setupLoadingView() {
        let LV = LoadingViewController()
        LV.modalPresentationStyle = .overCurrentContext
        loadingDelegate = LV
        self.present(LV, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            Log.d("Done Loading")
            timer.invalidate()
            self.loadingDelegate?.complete()
        }
    }
    
    // MARK: - General Setup
    func setup() {
        resetPosts()
        listenForAddition()
        listenForRemoval()
        listenForChanges()
        
        self.tabBarController?.tabBar.isHidden = true
        setupEmptyDataSet()
        if let type = AppSettings.userType {
            switch type {
            case .Reader, .Staff:
                if let button = self.newPostButton {
                    button.isEnabled = false
                }
                self.navigationItem.rightBarButtonItem = nil
            default:
                Log.d(type)
            }
        }
    }
    
    func resetPosts() {
        RealmHandler.resetJournalPosts()
        self.tableView.reloadData()
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
            
            imageCell.postPhoto.image = nil
            imageCell.layoutSubviews()
            imageCell.indicator = Utilities.createActivityIndicator(view: imageCell)
            imageCell.indicator.stopAnimating()
            
            let indicator = Utilities.createActivityIndicator(view: imageCell)
            imageCell.indicator = indicator
            imageCell.post = post
            imageCell.commentDelegate = self
            imageCell.timestamp.text = post.timestamp.toTimeStamp()
            
            imageCell.nameLabel.text = post.posterName
            if post.message == "" {
                imageCell.message.isHidden = true
            } else {
                imageCell.message.text = post.message
            }
            
            imageCell.postPhoto.clipsToBounds = true
            
            imageCell.message.layer.cornerRadius = 5
            imageCell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            imageCell.postPhoto.layer.cornerRadius = 5
            
            let commentCount = post.comments.count
            if commentCount > 0 {
                imageCell.commentsButton.setTitle("Comments (\(commentCount))   ", for: .normal)
            } else {
                imageCell.commentsButton.setTitle("Comments (0)   ", for: .normal)
            }
        
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as! JournalTableViewCell
            cell.layoutSubviews()
            
            cell.post = post
            cell.commentDelegate = self
            
            cell.nameLabel.text = post.posterName
            cell.message.text = post.message
            cell.timestamp.text = post.timestamp.toTimeStamp()
            
            cell.message.layer.cornerRadius = 5
            cell.message.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 12)
            if let img = ProfilePickerHandler.chosenPhoto {
                cell.userImage.image = img
                cell.userImage.setupSecondaryProfilePicture()
            } else {
                cell.userImage.image = #imageLiteral(resourceName: "Logo")
            }
            
            let commentCount = post.comments.count
            if commentCount > 0 {
                cell.commentsButton.setTitle("Comments (\(commentCount))   ", for: .normal)
            } else {
                cell.commentsButton.setTitle("Comments (0)   ", for: .normal)
            }
            
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if AppSettings.userType == DatabaseHandler.UserType.Patient || AppSettings.userType == DatabaseHandler.UserType.Family {
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
                    
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let post = self.posts[indexPath.row]
        
        if post.posterUID == AppSettings.currentAppUser!.id {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
                Log.d("Delete")
                self.deleteComment(post: post)
                
            }
            delete.backgroundColor = UIColor.red
            
            let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, nil) in
                Log.d("Edit")
                self.performSegue(withIdentifier: "showNewPost", sender: post)
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
            DatabaseHandler.database.child(co.journal.Journals).child(reader.readingFrom).child(post.id).setValue(nil)
        } else if let family = AppSettings.currentAppUser as? DatabaseHandler.Family {
            DatabaseHandler.database.child(co.journal.Journals).child(family.patient).child(post.id).setValue(nil)
        } else if let patient = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            DatabaseHandler.database.child(co.journal.Journals).child(patient.id).child(post.id).setValue(nil)
        }
    }
    
    func editComment(post: Post) {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            DatabaseHandler.database.child(co.journal.Journals).child(reader.readingFrom).child(post.id).updateChildValues(["Post": post.message])
        } else if let family = AppSettings.currentAppUser as? DatabaseHandler.Family {
            DatabaseHandler.database.child(co.journal.Journals).child(family.patient).child(post.id).updateChildValues(["Post": post.message])
        } else if let patient = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            DatabaseHandler.database.child(co.journal.Journals).child(patient.id).child(post.id).updateChildValues(["Post": post.message])
        }
    }
    
    func userDidSelectPostForComments(post: Post) {
        performSegue(withIdentifier: "viewPost", sender: post)
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
            Log.d("After:", posts.count)
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    var isFirstLoad = true
    func listenForAddition() {
//        if isFirstLoad {
//            // get all that data
//            DatabaseHandler.getPostsFromDB { (posts) in
//                if let posts = posts {
//                    self.posts = posts
//                    self.tableView.reloadData()
//                    self.isFirstLoad = false
//                }
//            }
//        }
        
        DatabaseHandler.listenForPostAdded { (newPost) in
//            if !self.isFirstLoad {
////                let posts = RealmHandler.getPostList()
////                self.posts = posts
////                self.tableView.reloadData()
//
//            }
            
            if let post = newPost {
                self.posts.insert(post, at: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
            
        }
    }
    
    func listenForChanges() {
        DatabaseHandler.listenForPostChange {
            let posts = RealmHandler.getPostList()
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
        var desc = ""
        if AppSettings.userType == .Patient {
            desc = "Click the 'compose' button at the top to write your first Journal entry!"
        }
        let attr = NSAttributedString(string: desc)
        return attr
    }

  
    // MARK: - Navigation
    var menuIsShowing: Bool = false
    @IBAction func toggleMenu(_ sender: Any) {
        
        MenuHandler.openMenu(vc: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPost" {
            if let vc = segue.destination as? ViewPostViewController {
                if let post = sender as? Post {
                    vc.post = post
                }
            }
        } else if segue.identifier == "showNewPost" {
            if let vc = segue.destination as? NewPostViewController {
                if let post = sender as? Post {
                    vc.postToEdit = post
                }
            }
        }
    }

    
}












