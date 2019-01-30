////
//  CallManager.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import Foundation
import CallKit
import FirebaseAuth

class CallManager {
    
    static func goOffline() {
        guard let user = AppSettings.currentAppUser as? DatabaseHandler.Staff else { return }
        let ref = DatabaseHandler.database.child("Staff").child(user.id)
        ref.child("isOnCall").setValue(false)
        ref.child("token").setValue("")
    }
    
    static func goOnline(with token: String? = nil) {
        guard let token  = token else { return }
        guard let user = Auth.auth().currentUser else { return }
        let ref = DatabaseHandler.database.child("Staff").child(user.uid)
        ref.child("isOnCall").setValue(true)
        guard !VideoCallDatabaseHandler.deviceToken.isEmpty else { return }
        ref.child("token").setValue(token)
    }
    
}

