//
//  Posts.swift
//  HumanityHospice
//
//  Created by App Center on 5/12/18.
//Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class Post: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var timestamp: TimeInterval = 0.0
    @objc dynamic var message: String = ""
    @objc dynamic var posterName: String = ""
    @objc dynamic var posterUID: String = ""
    let comments = List<Post>()
    @objc dynamic var isComment: Bool = false
    @objc dynamic var hasImage: Bool = false
    @objc dynamic var postImage: Data? = nil
    @objc dynamic var imageURL: String? = nil
    @objc dynamic var posterProfileURL: String? = nil
    @objc dynamic var posterProfilePicture: Data? = nil
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func initFrom(ref: DatabaseReference) {
        
    }
    
}

class EBPost: Object {
    @objc dynamic var id = ""
    @objc dynamic var timestamp: TimeInterval = 0.0
    @objc dynamic var message: String = ""
    @objc dynamic var posterName: String = ""
    @objc dynamic var posterUID: String = ""
    @objc dynamic var posterProfileURL: String? = nil
    @objc dynamic var posterProfilePicture: Data? = nil
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class PhotoAlbumPost: Object {
    @objc dynamic var id = ""
    @objc dynamic var timestamp: TimeInterval = 0.0
    @objc dynamic var url: String = ""
    @objc dynamic var caption: String? = nil
    @objc dynamic var image: Data? = nil
    @objc dynamic var name: String = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
}




