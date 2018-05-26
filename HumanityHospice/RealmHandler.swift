//
//  RealmHandler.swift
//  HumanityHospice
//
//  Created by App Center on 5/13/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHandler {
    private static var realm = try! Realm()
    
    // MARK: - Journal
    
    public static func resetJournalPosts() {
        let currentPosts = self.realm.objects(Post.self)
        if currentPosts.count > 0 {
            try! self.realm.write {
                self.realm.delete(currentPosts)
            }
            let posts = realm.objects(Post.self)
            print("Verifying Cleanout - Number of Posts:", posts.count)
        }
    }
    
    public static func getPostList() -> [Post] {
        let posts = Array(realm.objects(Post.self))
        
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
    }
    
    public static func getPost(id: String) -> Post? {
        if let post = realm.object(ofType: Post.self, forPrimaryKey: id) {
            return post
        } else {
            return nil
        }
    }
    
    public static func delete(post: Post, completion: (Bool)->()) {
        try! realm.write {
            realm.delete(post)
            completion(true)
        }
    }
    
    // MARK: - Encouragement Board
    
    public static func getEBPostList() -> [EBPost] {
        let posts = Array(realm.objects(EBPost.self))
        
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
    }
    
    // MARK: - Photo Album
    
    public static func resetPhotoAlbum() {
        let currentPosts = self.realm.objects(PhotoAlbumPost.self)
        if currentPosts.count > 0 {
            try! self.realm.write {
                self.realm.delete(currentPosts)
            }
            let posts = realm.objects(Post.self)
            print("Verifying Cleanout - Number of Photo Album Items:", posts.count)
        } else {
            print("Verifying Cleanout - Number of Photo Album Items:", currentPosts.count)
        }
    }
    
    public static func getPhotoAlbumPosts() -> [PhotoAlbumPost] {
        let posts = Array(realm.objects(PhotoAlbumPost.self))
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
    }
    
    
}
