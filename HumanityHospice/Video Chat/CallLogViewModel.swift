////
//  CallLogViewModel.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import Foundation
import UIKit


class CallLogViewModel {
    
    static var incomingCall: Call? = nil
    
    var calls: [Call] = []
 
    func format(timeinterval: TimeInterval) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        
        let dateString = formatter.string(from: Date(timeIntervalSince1970: timeinterval))
        
        return dateString
    }
    
    func refreshCallLog(completion: ()->()) {
        let objs = RealmHandler.realm.objects(Call.self)
        var calls = Array(objs)
        calls.sort { (call1, call2) -> Bool in
            return call1.timestamp > call2.timestamp
        }
        self.calls = calls
        completion()
    }
    
}
