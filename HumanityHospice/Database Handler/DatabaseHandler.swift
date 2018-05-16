//
//  DatabaseHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/18/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import RealmSwift

class DatabaseHandler {
    
    static let realm = try! Realm()
    
    // AUTH
    /// Signs in a user using Firebase/Auth
    ///
    /// - Parameters:
    ///   - email: Email address User used to sign up
    ///   - password: Password user used to sign up
    ///   - completion: completion hands back optional error, and optional user
    static func signIn(email: String, password: String, completion: @escaping (User?, Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(nil, error)
            } else {
                if user != nil {
                    completion(user, nil)
                }
            }
        }
    }
    
    /// Iterates through an array of possible Database headers, finds the header that has a child with the supplied user uid, sets the AppSettings.userType, and calls for a data pull at the specified location
    ///
    /// - Parameters:
    ///   - user: The current Firebase user
    static func fetchData(for user: User, completion: @escaping ()->()) {
        let ref = Database.database().reference()
        let paths = ["Patients", "Staff", "Readers", "Family"]
        var hasChild = false
        var selectedPath: DatabaseReference?
        
        var counter = 0
        for path in paths {
            let userPath = ref.child(path).child(user.uid)
            checkLocation(ref: userPath, completion: { (isPath) in
                counter += 1
                
                if isPath {
                    hasChild = true
                    selectedPath = userPath
                    let type = getType(type: path)
                    AppSettings.userType = type
                    pullDataFrom(kind: path, completion: { (done) in
                        if done {
                            completion()
                        }
                    })
                }
                
                if counter == paths.count {
                    if hasChild == false && selectedPath == nil {
                        do {
                            try! Auth.auth().signOut()
                            Utilities.closeActivityIndicator()
                            print("Signed Out bc failure to grab data")
                        }
                    }
                }
            })
        }
    }
    
    /// Checks each location supplied to see if the location contains a child with the current Firebase user UID
    ///
    /// - Parameters:
    ///   - ref: The reference to check
    ///   - completion: Hands back true
    private static func checkLocation(ref: DatabaseReference, completion: @escaping (Bool)->()) {
        ref.observeSingleEvent(of: .value) { (snap) in
            if snap.childrenCount > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private static func pullDataFrom(kind: String, completion: @escaping (Bool)->()) {
        Database.database().reference().child(kind).child(AppSettings.currentFBUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                switch AppSettings.userType! {
                case .Patient:
                    let familyID = data["FamilyID"] as! String
                    let inviteCode = data["InviteCode"] as! String
                    let meta = data["MetaData"] as! [String: Any]
                    let DOB = meta["DOB"] as! TimeInterval
                    let first = meta["firstName"] as! String
                    let last = meta["lastName"] as! String
                    
                    let user = Patient(id: AppSettings.currentFBUser!.uid,
                                       firstName: first, lastName: last, DOB: DOB, nurse: nil,
                                       inviteCode: inviteCode, familyID: familyID, profilePic: nil)
                    AppSettings.currentAppUser = user
                    AppSettings.currentPatient = user.id
                    completion(true)
                case .Reader:
                    let readingFrom = data["ReadingFrom"] as! String
                    let meta = data["MetaData"] as! [String: Any]
                    let first = meta["firstName"] as! String
                    let last = meta["lastName"] as! String
                    let user = Reader(id: AppSettings.currentFBUser!.uid, firstName: first, lastName: last, readingFrom: readingFrom, patients: nil, profilePic: nil)
                    AppSettings.currentAppUser = user
                    AppSettings.currentPatient = user.readingFrom
                    completion(true)
                default:
                    break
                }
            }
        }
    }
    
    static func getProfilePicture(completion: @escaping (Bool)->()) {
        if let user = AppSettings.currentFBUser {
            if let url = user.photoURL {
                let ref = Storage.storage().reference(forURL: url.absoluteString)
                ref.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        completion(false)
                    } else {
                        if let data = data {
                            if let img = UIImage(data: data) {
                                ProfilePickerHandler.chosenPhoto = img
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    }
                }
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    static func setProfilePicture(completion: @escaping (Bool, String?)->()) {
        let ref = Storage.storage().reference().child("ProfilePictures").child(AppSettings.currentFBUser!.uid)
        let name = "ProfilePicture.png"
        let profilePicRef = ref.child(name)
        
        if let img = ProfilePickerHandler.chosenPhoto {
            if let data = UIImagePNGRepresentation(img) {
                profilePicRef.putData(data, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        Utilities.closeActivityIndicator()
                        completion(false, error!.localizedDescription)
                    } else {
                        if let url = metadata?.downloadURLs![0] {
                            print("Download URL:", url)
                            
                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.photoURL = url
                            req?.commitChanges(completion: { (error) in
                                if error != nil {
                                    completion(false, error!.localizedDescription)
                                    Utilities.closeActivityIndicator()
                                } else {
                                    Utilities.closeActivityIndicator()
                                    completion(true, nil)
                                }
                            })
                        } else {
                            completion(false, "Couldn't get URL from meta data")
                        }
                    }
                })
            } else {
                completion(false, "Couldn't cast data to image")
            }
        }
    }
    
    static func signUp(email: String, password: String, completion: @escaping (User?, Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(nil, error)
            } else {
                if user != nil {
                    completion(user, nil)
                }
            }
        }
    }
    
    public static func createFamilAccount(first: String,
                                          last: String,
                                          email: String,
                                          pass: String, completion: @escaping ()->()) {
        FirebaseApp.configure(name: "CreatingUsersApp", options: FirebaseApp.app()!.options)
        
        if let secondaryApp = FirebaseApp.app(name: "CreatingUsersApp") {
            let secondaryAppAuth = Auth.auth(app: secondaryApp)
            secondaryAppAuth.createUser(withEmail: email, password: pass) { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if user != nil {
                        print("User Created! \(user!.uid) Updating Info")
                        let req = user?.createProfileChangeRequest()
                        req?.displayName = "\(first) \(last)"
                        req?.commitChanges(completion: { (error) in
                            if error != nil {
                                print("Couldn't perform profile changes")
                            } else {
                                print("Successfully changed profile information")
                                if let patient = AppSettings.currentPatient {
                                    let appuser = Family(id: user!.uid,
                                                         firstName: first,
                                                         lastName: last,
                                                         patient: patient,
                                                         profilePic: nil)
                                    
                                    DatabaseHandler.createUserReference(type: .Family,
                                                                        user: appuser,
                                                                        completion: { (error, done) in
                                                                            if error != nil {
                                                                                print("Error! :", error!.localizedDescription)
                                                                            } else {
                                                                                print("Created Family Account Reference")
                                                                                completion()
                                                                            }
                                    })
                                }
                            }
                        })
                    } else {
                        
                    }
                }
            }
        }
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
            while Auth.auth().currentUser != nil {
                print("Waiting to signout")
            }
            AppSettings.clearAppSettings()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // DATABASE
    /// Creates the database reference to the newly created user
    ///
    /// - Parameters:
    ///   - type: The type of user being created. Used to determine what group to add the user to
    ///   - user: The user object was created based on entered values.
    ///   - completion: Hands back an error if not null, and a success Boolean
    static func createUserReference(type: UserType, user: AppUser, completion: @escaping (Error?, Bool?)->()) {
        let ref = Database.database().reference()
        var userRef: DatabaseReference
        var dataToSend: [String: Any]
        
        switch type {
        case .Patient:
            let patient = user as! Patient
            userRef = ref.child("Patients").child(patient.id)
            let data: [String : Any] = ["MetaData": ["firstName": patient.firstName,
                                                       "lastName": patient.lastName,
                                                       "DOB": patient.DOB ?? 0.0],
                                       "Nurse": patient.nurse,
                                       "InviteCode": patient.inviteCode,
                                       "FamilyID": patient.familyID ?? ""]
            dataToSend = data
            
            self.addInviteCode(code: patient.inviteCode!, uid: patient.id)
            
        case .Family:
            let familyMember = user as! Family
            userRef = ref.child("Family").child(familyMember.id)
            
            let data: [String: Any] = ["MetaData": ["firstName": familyMember.firstName,
                                                    "lastName": familyMember.lastName],
                                       "Patient": familyMember.patient]
            dataToSend = data
        case .Reader:
            let reader = user as! Reader
            userRef = ref.child("Readers").child(reader.id)
            
            let data: [String: Any] = ["MetaData": ["firstName": reader.firstName,
                                                    "lastName": reader.lastName],
                                       "ReadingFrom": AppSettings.currentPatient ?? ""]
            
            dataToSend = data
            
        case .Staff:
            let staffer = user as! Staff
            userRef = ref.child("Staff").child(staffer.id)
            
            let data: [String: Any] = ["MetaData": ["firstName": staffer.firstName,
                                                    "lastName": staffer.lastName],
                                       "isAdmin": staffer.isAdmin]
            
            dataToSend = data
        }
        
        userRef.setValue(dataToSend, withCompletionBlock: { (error, ref) in
            if error != nil {
                completion(error, false)
            } else {
                completion(nil, true)
            }
        })
        
        
    }

    /// Sets data at a reference point
    ///
    /// - Parameters:
    ///   - ref: the location where the data should be updated
    ///   - children: the list of child strings
    ///   - data: the data being provided for update
    ///   - completion: Hands back an error if not null, and a success Boolean
    static func setData(ref: DatabaseReference, at children: [String], data: [String: Any], completion: @escaping (Error?, Bool?)->()) {
        var childPath = ref
        
        for child in children {
            childPath = childPath.child(child)
        }
        
        childPath.setValue(data) { (error, ref) in
            if error != nil {
                completion(error, false)
            } else {
                completion(nil, true)
            }
        }
    }
    
    static func addUserToFollow(pid: String, userID: String) {
        Database.database().reference().child("Readers").child(userID).child("Patients").child(pid).setValue(true)
    }
    
    static func setCurrentPatientToReadFrom(patientID: String, followerID: String) {
        Database.database().reference().child("Readers").child(followerID).child("ReadingFrom").setValue(patientID)
    }
    
    static func createAppUser(user: User) -> AppUser? {
        switch AppSettings.userType! {
        case .Patient:
            let code = self.generateUserInviteCode()
            let appuser = Patient(id: user.uid,
                                  firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                  DOB: nil, nurse: nil, inviteCode: code, familyID: nil, profilePic: nil)
            return appuser
        case .Reader:
            let appuser = Reader(id: user.uid,
                                 firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                 readingFrom: "", patients: nil, profilePic: nil)
            return appuser
        default:
            print("Error")
            return nil
        }
    }
    
    private static func generateUserInviteCode() -> String {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let array = Array(alphabet)
        var code = ""
        for _ in 0..<6 {
            let random = arc4random_uniform(26)
            let letter = array[Int(random)]
            code.append(letter)
        }
        
        return code
    }
    
    static func addInviteCode(code: String, uid: String) {
        Database.database().reference().child("InviteCodes").child(code).child("patient").setValue(uid)
    }
    
    static func checkDBForInviteCode(code: String, completion: @escaping (Bool, String?)->()) {
        let ref = Database.database().reference()
        ref.child("InviteCodes").child(code).observeSingleEvent(of: .value) { (snap) in
            if snap.hasChildren() {
                if let data = snap.value as? [String: Any] {
                    let patient = data["patient"] as! String
                    completion(true, patient)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    // MARK: - Journal Posts
    public static var postWatcherDelegate: PostWatcher?
    public static func getPostsFromDB(completion: @escaping ([Post]?)->()) {
        let ref = Database.database().reference().child("Journals")
        var userRef: DatabaseReference?
        
        switch AppSettings.userType! {
        case .Patient:
            if let user = AppSettings.currentAppUser as? Patient {
                let uRef = ref.child(user.id)
                userRef = uRef
            }
        case .Reader:
            if let user = AppSettings.currentAppUser as? Reader {
                if user.readingFrom != "" {
                    let uref = ref.child(user.readingFrom)
                    userRef = uref
                } else {
                    let uref = ref.child(AppSettings.currentPatient!)
                    userRef = uref
                }
            }
        case .Family:
            if let user = AppSettings.currentAppUser as? Family {
                let uref = ref.child(user.patient)
                userRef = uref
            }
        default:
            print("User is staff")
        }
        
        if userRef != nil {
            userRef!.observeSingleEvent(of: .value) { (snap) in
                if snap.childrenCount > 0 {
                    
                    // the entire list
                    if let postList = snap.children.allObjects as? [DataSnapshot] {
                        
                        var posts: [Post] = []
                        for data in postList {
                            if let post = data.value as? [String: AnyObject] {
                                let timestamp = post["timestamp"] as! TimeInterval
                                let poster = post["poster"] as! String
                                let message = post["post"] as! String
                                let id = data.key
                                
                                // get comments, if any
                                var comments: [Post] = []
                                if let commentList = post["comments"] as? [DataSnapshot] {
                                    for commentData in commentList {
                                        if let comment = commentData.value as? [String: AnyObject] {
                                            let timestamp = comment["timestamp"] as! TimeInterval
                                            let poster = comment["poster"] as! String
                                            let message = comment["post"] as! String
                                            let id = commentData.key
                                            
                                            let newComment = Post()
                                            newComment.id = id
                                            newComment.timestamp = timestamp
                                            newComment.message = message
                                            newComment.poster = poster
                                            newComment.isComment = true
                                            
                                            comments.append(newComment)
                                        }
                                    }
                                    
                                    try! realm.write {
                                        realm.add(comments)
                                    }
                                }
                                
                                // create new object
                                let newPost = Post()
                                newPost.timestamp = timestamp
                                newPost.id = id
                                newPost.message = message
                                newPost.poster = poster
                                
                                // add comments, if any
                                if comments.count > 0 {
                                    newPost.comments.append(objectsIn: comments)
                                }
                                
                                // add image, if any
                                if let imageURL = post["postImageURL"] as? String {
                                    newPost.hasImage = true
                                    newPost.imageURL = imageURL
                                    posts.append(newPost)
                                } else {
                                    newPost.hasImage = false
                                    newPost.imageURL = nil
                                    posts.append(newPost)
                                }
                            }
                        }
                        for post in posts {
                            if post.comments.count > 1 {
                                let sorted = post.comments.sorted(by: { (p1, p2) -> Bool in
                                    return p1.timestamp > p2.timestamp
                                })
                                post.comments.removeAll()
                                post.comments.append(objectsIn: sorted)
                            }
                        }
                        let sortedPosts: [Post] = posts.sorted(by: { (p1, p2) -> Bool in
                            return p1.timestamp > p2.timestamp
                        })
                        
                        try! realm.write {
                            realm.add(sortedPosts)
                        }

                        completion(sortedPosts)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    public static var isFirstLoad = true
    public static var addedListenerHandle: DatabaseHandle?
    public static var removedListenerHandle: DatabaseHandle?
    public static func listenForPostAdded(completion: @escaping ()->()) {
        
        let ref = Database.database().reference().child("Journals")
        var userRef: DatabaseReference?
        
        switch AppSettings.userType! {
        case .Patient:
            if let user = AppSettings.currentAppUser as? Patient {
                let uRef = ref.child(user.id)
                userRef = uRef
            }
        case .Reader:
            if let user = AppSettings.currentAppUser as? Reader {
                if user.readingFrom != "" {
                    let uref = ref.child(user.readingFrom)
                    userRef = uref
                } else {
                    let uref = ref.child(AppSettings.currentPatient!)
                    userRef = uref
                }
            }
        case .Family:
            if let user = AppSettings.currentAppUser as? Family {
                let uref = ref.child(user.id)
                userRef = uref
            }
        default:
            print("User is staff")
        }
        
        if userRef != nil {
            let handle = userRef!.observe(.childAdded) { (snap) in
                var posts: [Post] = []
                if let post = snap.value as? [String: AnyObject] {
                    let timestamp = post["timestamp"] as! TimeInterval
                    let poster = post["poster"] as! String
                    let message = post["post"] as! String
                    let id = snap.key
                    
                    // get comments, if any
                    var comments: [Post] = []
                    if let commentList = post["comments"] as? [DataSnapshot] {
                        for commentData in commentList {
                            if let comment = commentData.value as? [String: AnyObject] {
                                let timestamp = comment["timestamp"] as! TimeInterval
                                let poster = comment["poster"] as! String
                                let message = comment["post"] as! String
                                let id = commentData.key
                                
                                let newComment = Post()
                                newComment.id = id
                                newComment.timestamp = timestamp
                                newComment.message = message
                                newComment.poster = poster
                                newComment.isComment = true
                                
                                comments.append(newComment)
                            }
                        }
                        
                        try! realm.write {
                            realm.add(comments)
                        }
                    }
                    
                    // create new object
                    let newPost = Post()
                    newPost.timestamp = timestamp
                    newPost.id = id
                    newPost.message = message
                    newPost.poster = poster
                    
                    // add comments, if any
                    if comments.count > 0 {
                        newPost.comments.append(objectsIn: comments)
                    }
                    
                    // add image, if any
                    if let imageURL = post["postImageURL"] as? String {
                        newPost.hasImage = true
                        newPost.imageURL = imageURL
                        posts.append(newPost)
                    } else {
                        newPost.hasImage = false
                        newPost.imageURL = nil
                        posts.append(newPost)
                    }
                }
                    
                for post in posts {
                    if post.comments.count > 1 {
                        
                        let sorted = post.comments.sorted(by: { (p1, p2) -> Bool in
                            return p1.timestamp > p2.timestamp
                        })
                        
                        post.comments.removeAll()
                        post.comments.append(objectsIn: sorted)
                        
                    }
                }
                
                let sortedPosts: [Post] = posts.sorted(by: { (p1, p2) -> Bool in
                    return p1.timestamp > p2.timestamp
                })
                
                
                // Make sure post is written
                let postCheck = RealmHandler.getPostList()
                print("Before:", postCheck.count)
                try! realm.write {
                    realm.add(sortedPosts, update: true)
                }
                completion()
            }
            
            addedListenerHandle = handle
        }
    }

    public static func listenForPostRemoved(completion: @escaping ()->()) {
        let ref = Database.database().reference().child("Journals")
        var userRef: DatabaseReference?
        
        switch AppSettings.userType! {
        case .Patient:
            if let user = AppSettings.currentAppUser as? Patient {
                let uRef = ref.child(user.id)
                userRef = uRef
            }
        case .Reader:
            if let user = AppSettings.currentAppUser as? Reader {
                if user.readingFrom != "" {
                    let uref = ref.child(user.readingFrom)
                    userRef = uref
                } else {
                    let uref = ref.child(AppSettings.currentPatient!)
                    userRef = uref
                }
            }
        case .Family:
            if let user = AppSettings.currentAppUser as? Family {
                let uref = ref.child(user.id)
                userRef = uref
            }
        default:
            print("User is staff")
        }
        
        if userRef != nil {
            let handle = userRef!.observe(.childRemoved) { (snap) in
                if let post = snap.value as? [String: AnyObject] {
                    let id = snap.key
                    
                    if let delete = RealmHandler.getPost(id: id) {
                        RealmHandler.delete(post: delete, completion: { (done) in
                            if done {
                                completion()
                            }
                        })
                    }
                }
            }
            removedListenerHandle = handle
        }
    }
    
    public static func postToDatabase(poster: String, name: String, message: String, imageURL: String?, completion: ()->()) {
        
        if imageURL != nil {
            let ref = Database.database().reference().child("Journals").child(poster).childByAutoId()
            let data: [String: Any] = ["poster": name,
                                       "post": message,
                                       "timestamp": Date().timeIntervalSince1970,
                                       "postImageURL": imageURL!]
            ref.setValue(data)
            completion()
        } else {
            let ref = Database.database().reference().child("Journals").child(poster).childByAutoId()
            let data: [String: Any] = ["poster": name,
                                       "post": message,
                                       "timestamp": Date().timeIntervalSince1970]
            ref.setValue(data)
            completion()
        }
    }
    public static func removeFromDatabase(post: Post, completion: @escaping (Bool)->()) {
        if post.hasImage {
            if let url = post.imageURL {
                let ref = Storage.storage().reference(forURL: url)
                ref.delete { (error) in
                    if error != nil {
                        print("Error! Couldn't delete the photo at that location")
                        completion(false)
                    } else {
                        print("Successfully deleted Photo from storage")
                        
                        let patient = Database.database().reference().child("Journals").child(AppSettings.currentPatient!)
                        let pRef = patient.child(post.id)
                        pRef.setValue(nil)
                        completion(true)
                    }
                }
            }
        } else {
            let patient = Database.database().reference().child("Journals").child(AppSettings.currentPatient!)
            let pRef = patient.child(post.id)
            pRef.setValue(nil)
            completion(true)
        }
    }
    
    public static func postImageToDatabase(image: UIImage, completion: @escaping (String?, Error?)->()) {
        if let data = UIImagePNGRepresentation(image) {
            let uid = AppSettings.currentFBUser!.uid
            let date = Int(Date().timeIntervalSince1970.rounded())
            let ref = Storage.storage().reference().child("Journals").child(uid).child("PostImages").child("post-\(date)")
            ref.putData(data, metadata: nil) { (meta, error) in
                if error != nil {
                    completion(nil, error)
                } else {
                    if let url = meta!.downloadURLs!.first {
                        completion(url.absoluteString, nil)
                    }
                }
            }
        }
    }
    
    public static var currentPostStack: [String] = []
    public static func checkForImageChanges(urlFromDB url: URL) -> Bool {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let name = ref.name
        
        for img in currentPostStack {
            if img == name {
                return true
            } else {
                currentPostStack.append(name)
                return false
            }
        }
        
        return false
    }
    
    public static func getImageFromStorage(url: URL, completion: @escaping (UIImage?, Error?)->()) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        ref.getData(maxSize: 20 * 1024 * 1024) { (data, error) in
            if error != nil {
                completion(nil, error!)
            } else {
                if let data = data {
                    if let img = UIImage(data: data) {
                        completion(img, nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Encouragement Board
    
    public static func getEBPosts(completion: @escaping ([EBPost])->()) {
        let ref = Database.database().reference().child("EncouragementBoard")
        guard let patient = AppSettings.currentPatient else { return }
        let userRef = ref.child(patient)
        
        userRef.observeSingleEvent(of: .value) { (snap) in
            if snap.childrenCount > 0 {
                if let children = snap.children.allObjects as? [DataSnapshot] {
                    
                    var posts: [EBPost] = []
                    
                    for data in children {
                        if let post = data.value as? [String: AnyObject] {
                            let name = post["poster"] as! String
                            let poster = post["posterID"] as! String
                            let timestamp = post["timestamp"] as! TimeInterval
                            let message = post["post"] as! String
                            
//                            let newPost = EBPost(timestamp: timestamp, message: message, posterID: poster, posterName: name)
//                            posts.append(newPost)
                            
                            let newPost = EBPost()
                            newPost.timestamp = timestamp
                            newPost.message = message
                            newPost.posterID = poster
                            newPost.posterName = name
                            
                            posts.append(newPost)
                            
                        }
                    }
                    
                    try! realm.write {
                        realm.add(posts)
                    }
                    
                    completion(posts)
                }
            }
        }
    }
    
    public static func postEBToDatabase(posterID: String, posterName: String, message: String, completion: ()->()) {
        let data: [String: Any] = ["posterID": posterID,
                                   "poster": posterName,
                                   "post": message,
                                   "timestamp": Date().timeIntervalSince1970]
        let ref = Database.database().reference().child("EncouragementBoard").child(AppSettings.currentPatient!).childByAutoId()
        ref.setValue(data)
        completion()
    }
    
    
    // MARK: - Object Stuff
    
    enum UserType {
        case Staff
        case Patient
        case Family
        case Reader
    }
    
    private static func getType(type: String) -> UserType {
        switch type {
        case "Staff":
            return .Staff
        case "Patients":
            return .Patient
        case "Family":
            return .Family
        case "Readers":
            return .Reader
        default:
            return .Staff
        }
    }
    
    struct Staff: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        var isAdmin: Bool
    }
    
    struct Patient: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        var DOB: TimeInterval?
        var nurse: Staff?
        let inviteCode: String?
        let familyID: String?
        var profilePic: UIImage? = nil
    }
    
    struct Family: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        let patient: String
        var profilePic: UIImage? = nil
    }
    
    struct Reader: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        var readingFrom: String
        var patients: [Patient]?
        var profilePic: UIImage? = nil
    }
    
    struct Journal: DatabaseObject {
        var id: String
        var posts: [Post]
    }
    
    
    struct Board: DatabaseObject {
        var id: String
        var posts: [Post]
    }
    
    struct Album: DatabaseObject {
        var id: String
        var posts: [ImagePost]
    }
    
    struct ImagePost: DatabaseObject {
        var id: String
        let ref: String
    }
    
    
}

protocol AppUser {
    var id: String { get set }
    var firstName: String { get set }
    var lastName: String { get set }
}

protocol DatabaseObject {
    var id: String { get set }
}

protocol PostWatcher {
    func didCompletePostFetch(posts: [Post])
}

extension AppUser {
    func changeName(changingFirst: Bool, newName: String, completion: @escaping (Error?)->()) {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        if changingFirst {
            request?.displayName = "\(newName) \(self.lastName)"
        } else {
            request?.displayName = "\(self.firstName) \(newName)"
        }
        request?.commitChanges(completion: { (error) in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
}

class dPost {
    let timestamp: TimeInterval
    let message: String
    let poster: String
    var comments: [Post]?
    var isComment: Bool?
    var hasImage: Bool = false
    var postImage: UIImage?
    var imageURL: URL?
    
    init(timestamp: TimeInterval, message: String, poster: String, comments: [Post]?, isComment: Bool?) {
        self.timestamp = timestamp
        self.message = message
        self.poster = poster
        self.comments = comments
        self.isComment = isComment
    }
}

class dEBPost {
    let timestamp: TimeInterval
    let message: String
    let posterName: String
    let posterID: String
    
    init(timestamp: TimeInterval, message: String, posterID: String, posterName: String) {
        self.timestamp = timestamp
        self.message = message
        self.posterID = posterID
        self.posterName = posterName
    }
}












