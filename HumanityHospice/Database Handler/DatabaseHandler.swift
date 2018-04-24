//
//  DatabaseHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/18/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import Firebase

class DatabaseHandler {
    
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
    static func fetchData(for user: User) {
        let ref = Database.database().reference()
        let paths = ["Patients", "Staff", "Readers", "Family"]
        var hasChild = false
        var selectedPath: DatabaseReference?
        
        for path in paths {
            let userPath = ref.child(path).child(user.uid)
            checkLocation(ref: userPath, completion: { (isPath) in
                if isPath {
                    hasChild = true
                    selectedPath = userPath
                    let type = getType(type: path)
                    AppSettings.userType = type
                    pullDataFrom(kind: path)
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
    
    private static func pullDataFrom(kind: String) {
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
                                       inviteCode: inviteCode, familyID: familyID)
                    AppSettings.currentAppUser = user
                case .Reader:
                    let readingFrom = data["ReadingFrom"] as! String
                    let meta = data["MetaData"] as! [String: Any]
                    let first = meta["firstName"] as! String
                    let last = meta["lastName"] as! String
                    let user = Reader(id: AppSettings.currentFBUser!.uid, firstName: first, lastName: last, readingFrom: readingFrom, patients: nil)
                    AppSettings.currentAppUser = user
                    
                default:
                    break
                }
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
        case .Family:
            let familyMember = user as! Family
            userRef = ref.child("Family").child(familyMember.id)
            
            let data: [String: Any] = ["MetaData": ["firstName": familyMember.firstName,
                                                    "lastName": familyMember.lastName],
                                       "Patient": familyMember.patient.id]
            dataToSend = data
        case .Reader:
            let reader = user as! Reader
            userRef = ref.child("Readers").child(reader.id)
            
            let data: [String: Any] = ["MetaData": ["firstName": reader.firstName,
                                                    "lastName": reader.lastName],
                                       "ReadingFrom": reader.readingFrom]
            
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
    
    static func createAppUser(user: User) -> AppUser? {
        switch AppSettings.userType! {
        case .Patient:
            let code = self.generateUserInviteCode()
            let appuser = Patient(id: user.uid,
                                  firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                  DOB: nil, nurse: nil, inviteCode: code, familyID: nil)
            return appuser
        case .Reader:
            let appuser = Reader(id: user.uid,
                                 firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                 readingFrom: "", patients: nil)
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
    
    
    enum UserType {
        case Staff
        case Patient
        case Family
        case Reader
    }
    
    static func getType(type: String) -> UserType {
        switch type {
        case "Staff":
            return .Staff
        case "Patient":
            return .Patient
        case "Family":
            return .Family
        case "Reader":
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
    }
    
    struct Family: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        let patient: Patient
    }
    
    struct Reader: AppUser {
        var id: String
        var firstName: String
        var lastName: String
        var readingFrom: String
        var patients: [Patient]?
    }
    
    struct Journal: DatabaseObject {
        var id: String
        var posts: [Post]
    }
    
    struct Post: DatabaseObject {
        var id: String
        let poster: String
        let timestamp: TimeInterval
        let message: String
        let comments: [Post]?
        var isComment: Bool?
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



