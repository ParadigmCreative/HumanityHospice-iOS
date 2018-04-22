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
                                       "InviteCode": patient.inviteCode ?? "",
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
            let appuser = Patient(id: user.uid,
                                  firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                  DOB: nil, nurse: nil, inviteCode: nil, familyID: nil)
            return appuser
        case .Reader:
            let appuser = Reader(id: user.uid,
                                 firstName: AppSettings.signUpName!.first, lastName: AppSettings.signUpName!.last,
                                 readingFrom: nil, patients: nil)
            return appuser
        default:
            print("Error")
            return nil
        }
    }
    
    enum UserType {
        case Staff
        case Patient
        case Family
        case Reader
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
        var readingFrom: Patient?
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

protocol DatabaseObject {
    var id: String { get set }
}



