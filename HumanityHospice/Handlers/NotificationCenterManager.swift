//
//  NotificationCenterManager.swift
//  HumanityHospice
//
//  Created by App Center on 12/21/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UserNotifications
import FirebaseDatabase

class NotificationDispatch {
    static var center: UNUserNotificationCenter = .current()
    static var options: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    static public func startRequest() {
        center.requestAuthorization(options: self.options) { (granted, error) in
            guard error == nil else {
                Log.e(error!.localizedDescription)
                return
            }
            
            if granted {
                // Register for notifications
            } else {
                Log.e("You will not be notified of updates")
            }
        }
    }
    
    static public func getNotificationSettings() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.startRequest()
            } else {
                // Make sure user is registered
            }
        }
    }
    
    static private func createRequest(title: String, body: String, sound: UNNotificationSound = UNNotificationSound.default()) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        
        return content
    }
    
    static private func triggerRequest(title: String, body: String, sound: UNNotificationSound = .default()) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let content = createRequest(title: title, body: body, sound: sound)
        let identifier = "UYLLocalNotification \(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            guard error == nil else {
                Log.e(error!.localizedDescription)
                return
            }
        }
    }
    
    static public func notifyCurrentUser(name: String, type: NotificationType) {
        switch type {
        case .NewJournalPost:
            // Patient posted an update in their journal
            triggerRequest(title: "New Journal Post", body: "\(name) has posted an update in their journal")
        case .NewJournalComment:
            // User commented on your journal post
            triggerRequest(title: "New Comment on your Journal Post", body: "\(name) has commented on your journal post")
        case.NewEncouragementPost:
            // User Sent you encouragement
            triggerRequest(title: "New Encouragement", body: "\(name) has sent you encouragement")
        }
    }
    
    static public func triggerNotification(for type: NotificationType) {
        var ref = DatabaseHandler.database.child("NotificationCenter").child(AppSettings.currentPatient!)
        if AppSettings.currentAppUser is DatabaseHandler.Patient || AppSettings.currentAppUser is DatabaseHandler.Family {
            ref = ref.child("Patient")
        } else {
            ref = ref.child("Global")
        }
        
        switch type {
        case .NewEncouragementPost:
            let data = ["UserName": "\(AppSettings.currentAppUser!.fullName())",
                        "Action": "Sent you encouragement"]
            ref.childByAutoId().setValue(data)
            removeTriggerAfterSetTime(time: 65, type: type, ref: ref)
        case .NewJournalComment:
            let data = ["UserName": "\(AppSettings.currentAppUser!.fullName())",
                        "Action": "Sent you encouragement"]
            ref.childByAutoId().setValue(data)
            removeTriggerAfterSetTime(time: 65, type: type, ref: ref)
        case .NewJournalPost:
            ref.child("didUpdateJournal").setValue("True")
            removeTriggerAfterSetTime(time: 65, type: type, ref: ref)
        }
    }
    
    static private func removeTriggerAfterSetTime(time: TimeInterval, type: NotificationType, ref: DatabaseReference) {
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            switch type {
            case .NewJournalPost:
                ref.setValue(false)
            case .NewEncouragementPost, .NewJournalComment:
                ref.setValue(nil)
            }
        }
    }
    
    enum NotificationType {
        case NewJournalPost
        case NewJournalComment
        case NewEncouragementPost
    }
    
}
