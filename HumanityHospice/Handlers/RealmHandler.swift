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
    static var realm = try! Realm()
    
    // MARK: - General
    static func write(_ completion: @escaping (Realm)->()) {
        DispatchQueue.main.async {
            completion(self.realm)
        }
    }
    
    
    
    // MARK: - Journal
    
    public static func resetJournalPosts() {
        DispatchQueue.main.async {
            let currentPosts = self.realm.objects(Post.self)
            if currentPosts.count > 0 {
                try! self.realm.write {
                    self.realm.delete(currentPosts)
                }
                let posts = realm.objects(Post.self)
                Log.i("Verifying Cleanout - Number of Posts:", posts.count)
                resetComments()
            }
        }
    }
    
    public static func getPostList() -> [Post] {
        let posts = Array(realm.objects(Post.self))
        
        let filtered = posts.filter { (post) -> Bool in
            return post.isComment == false
        }
        
        let sorted = filtered.sorted { (p1, p2) -> Bool in
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
    
    public static func resetComments() {
        let comments = realm.objects(Post.self).filter { (post) -> Bool in
            return post.isComment == true
        }
        
        try! realm.write {
            realm.delete(comments)
        }
        
    }
    
    public static func getComments() -> [Post] {
        let posts = Array(realm.objects(Post.self))
        
        let filtered = posts.filter { (post) -> Bool in
            return post.isComment == true
        }
        
        let sorted = filtered.sorted { (p1, p2) -> Bool in
            return p1.timestamp < p2.timestamp
        }
        
        return sorted
    }
    
    // MARK: - Encouragement Board
    
    public static func getEBPostList() -> [EBPost] {
        let posts = Array(realm.objects(EBPost.self))
        
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
    }
    
    public static func resetEBPostList() {
        let currentPosts = self.realm.objects(EBPost.self)
        if currentPosts.count > 0 {
            try! self.realm.write {
                self.realm.delete(currentPosts)
            }
        }
    }
    
    // MARK: - Photo Album
    
    public static func resetPhotoAlbum() {
        let currentPosts = self.realm.objects(PhotoAlbumPost.self)
        if currentPosts.count > 0 {
            try! self.realm.write {
                self.realm.delete(currentPosts)
            }
        }
    }
    
    public static func getPhotoAlbumPosts() -> [PhotoAlbumPost] {
        let posts = Array(realm.objects(PhotoAlbumPost.self))
        let sorted = posts.sorted { (p1, p2) -> Bool in
            return p1.timestamp > p2.timestamp
        }
        
        return sorted
    }
    
    // MARK: - Master
    public static func masterResetRealm() {
        DispatchQueue.main.async {
            resetComments()
            resetPhotoAlbum()
            resetJournalPosts()
            resetEBPostList()
        }
    }
    
}
