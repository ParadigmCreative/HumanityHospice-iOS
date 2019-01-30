//
//  AppDelegate.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/17/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import RealmSwift
import UserNotifications
import CallKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "HumanityConnect"))
    let callController = CXCallController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let options: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            guard error == nil else { return }
            Log.d("Granted:", granted)
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                
                let answerCallAction = UNNotificationAction(identifier: NotificationDispatch.NotificationType.Call.rawValue + "answer",
                                                      title: "AnswerCall", options: [])
                let declineCallAction = UNNotificationAction(identifier: NotificationDispatch.NotificationType.Call.rawValue + "decline",
                                                            title: "DeclineCall", options: [])
                
                let category = UNNotificationCategory(identifier: "callCategory",
                                                      actions: [answerCallAction, declineCallAction],
                                                      intentIdentifiers: [], options: [])
                
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            })
        }
        
        let version: UInt64 = 3
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: version,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                
                if (oldSchemaVersion < version) {

                    print("*****")
                    print()
                    print("Local Realm Version:", version)
                    print()
                    print("*****")
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        RealmHandler.masterResetRealm()
        
        initProvider()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Log.d("Did Enter Background")
//        application.setMinimumBackgroundFetchInterval(1 * 60)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Log.d("Did Become Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        Log.d("Will Terminate")
        
        DatabaseHandler.closeConnections()

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Log.i("Device Token:", token)
        // Update device token
        AppSettings.currentDeviceToken = token
        Messaging.messaging().apnsToken = deviceToken
        InstanceID.instanceID().instanceID { (result, error) in
            guard error == nil else {
                Log.e(error!.localizedDescription)
                return
            }
            guard let result = result else { return }
            Log.i("InstanceID:", result.instanceID)
            Log.i("Token:", result.token)
            VideoCallDatabaseHandler.deviceToken = result.token
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.s("Failed to register:", error.localizedDescription)
        // Ask to register?
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let data = userInfo["gcm.message_id"]
        Log.d(userInfo as! [String: Any])
        Log.d(data)
        
        let callerID = userInfo["gcm.notification.patientID"]! as! String
        let action = userInfo["gcm.notification.action"]! as! String
        let alert = userInfo["aps"] as! [String: Any]
        let innerAlert = alert["alert"]! as! [String: String]
        let title = innerAlert["title"]
        let body = innerAlert["body"]
        
        VideoCallDatabaseHandler.parseAPN(action: action, patientID: callerID, title: title!, body: body!) { (delegate, session, call) in
            let update = CXCallUpdate()
            update.hasVideo = true
            update.remoteHandle = CXHandle(type: .generic, value: call.patientName)
            let uuid = UUID()
            VideoCallDatabaseHandler.currentUUID = uuid
            provider.reportNewIncomingCall(with: uuid, update: update, completion: { error in })
        }
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // Update in Firebase
        Log.d("FCM Token:", fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Log.d("Remote Message:", remoteMessage.appData)
    }
    
}

extension AppDelegate: CXProviderDelegate {
    
    func initProvider() {
        provider.setDelegate(self, queue: nil)
        
    }
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        Log.i("Answered")
        action.fulfill()
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "CallAnswered"), object: nil)

        guard let uuid = VideoCallDatabaseHandler.currentUUID else { return }
        let end = CXEndCallAction(call: uuid)
        let trans = CXTransaction(action: end)
        callController.request(trans) { (error) in
            Log.e(error?.localizedDescription)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        Log.i("Ended")
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        Log.i("Started")
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        Log.i("Started Audio")
    }
    
    func request(transaction: CXTransaction) {
        callController.request(transaction) { (error) in
            Log.d(error?.localizedDescription)
        }
    }
    
}
