////
//  VideoCallDatabaseManager.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CallKit

protocol VideoCallDelegate {
    func goToVideo(sessionID: String, call: Call)
    func showJoinAlert(sessionID: String, call: Call)
}

class VideoCallDatabaseHandler {
    
    public static var deviceToken: String = ""
    
    private static let ref = Database.database().reference()
    private static let staff = ref.child("Staff")
    private static let patients = ref.child("Patients")
    private static let notificationCenter = ref.child("NotificationCenter").child("Calls")
    
    public static var delegate: VideoCallDelegate?
    
    enum APNActions: String {
        case VideoCall = "VideoCall"
        case JournalPost = "JournalPost"
        case JournalComment = "JournalComment"
        case EncouragementPost = "EncouragementPost"
    }
    
    public static func requestCallToNurse(completion: @escaping (VideoChatViewController?, DatabaseHandler.StaffError?)->()) {
        if let user = AppSettings.currentAppUser as? DatabaseHandler.Patient {
            DatabaseHandler.pullDataFrom(kind: "Patients") { (done) in
                guard let nurseid = user.nurseID else { return }
                
                DatabaseHandler.getOnCallNurseDetails(nurseID: nurseid, completion: { (error, nurseID, token) in
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    
                    let request: [String: Any] = ["greeting": "\(user.fullName()) is calling you! Tap here to answer.",
                        "nurseID": nurseid,
                        "patientID": user.id]
                    
                    notificationCenter.childByAutoId().setValue(request)
                    if let vc = UIStoryboard(name: "Nurse", bundle: nil).instantiateViewController(withIdentifier: "videoVC") as? VideoChatViewController {
                        vc.uuid = UInt(bitPattern: user.id.hashValue)
                        vc.sessionID = user.id
                        
                        completion(vc, nil)
                    }
                })
            }
        }
    }
    
    public static func updateTokenInDatabase() {
        guard self.deviceToken.isEmpty == false else { return }
        let token = self.deviceToken
        
        switch AppSettings.userType! {
        case DatabaseHandler.UserType.Patient:
            patients.child(AppSettings.currentAppUser!.id).child("token").setValue(token)
        case DatabaseHandler.UserType.Staff:
            staff.child(AppSettings.currentAppUser!.id).child("token").setValue(token)
        default:
            break
        }
    }
    
    public static func set(delegate: VideoCallDelegate) {
        self.delegate = delegate
    }
    
    public static func parseAndSendLocal(action: String, patientID: String, title: String, body: String,
                                         completion: (VideoCallDelegate?, String, Call)->()) {
        guard let action = APNActions(rawValue: action) else { return }
        
        switch action {
        case .VideoCall:
            let date = Date().timeIntervalSince1970
            let name = title.components(separatedBy: "is calling").first!
            
            let call = Call()
            call.id = "\(patientID)-\(date)"
            call.patientID = patientID
            call.patientName = name
            call.timestamp = date
            
            try! RealmHandler.realm.write {
                RealmHandler.realm.add(call)
            }
//            delegate?.showJoinAlert(sessionID: patientID, call: call)
            completion(delegate, patientID, call)
            
        default:
            break
        }
    }
    
    public static func parseAPN(action: String, patientID: String, title: String, body: String, completion: (VideoCallDelegate?, String, Call)->()) {
        guard let action = APNActions(rawValue: action) else { return }
        
        switch action {
        case .VideoCall:
            let date = Date().timeIntervalSince1970
            let name = title.components(separatedBy: "is calling").first!
            
            let call = Call()
            call.id = "\(patientID)-\(date)"
            call.patientID = patientID
            call.patientName = name
            call.timestamp = date
            
            try! RealmHandler.realm.write {
                RealmHandler.realm.add(call)
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "CallAnswered"),
                                                   object: nil,
                                                   queue: nil, using: { (notification) in
                delegate?.goToVideo(sessionID: patientID, call: call)
            })
            completion(delegate, patientID, call)
        default:
            break
        }
    }
    
    public static func startVideo(patientID: String, call: Call) {
        delegate!.goToVideo(sessionID: patientID, call: call)
    }
    
    public static var currentUUID: UUID? = nil
    public static func endCall() {
        let appD = UIApplication.shared.delegate as! AppDelegate
        guard let uuid = currentUUID else { return }
        let end = CXEndCallAction(call: uuid)
        let trans = CXTransaction(action: end)
        appD.callController.request(trans) { (error) in
            Log.e(error?.localizedDescription)
        }
    }
    
}
