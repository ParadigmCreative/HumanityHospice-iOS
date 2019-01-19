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
    
    public static func notify(type: NotificationType, callerName: String) {
        
        let id = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "\(callerName) is calling!"
        content.body = "Tap here to answer"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = type.rawValue
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let notification = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        
        center.removeAllPendingNotificationRequests()
        center.add(notification) { (error) in
            guard error == nil else {
                Log.e(error!.localizedDescription)
                return
            }
        }
        
    }
    
    enum NotificationType: String {
        case Call = "Call"
        case NewJournalPost = "NewJournalPost"
        case NewJournalComment = "NewJournalComment"
        case NewEncouragementPost = "NewEncouragementPost"
    }
    
}
