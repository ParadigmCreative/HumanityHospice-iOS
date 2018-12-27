//
//  AppDelegate.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/17/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationDispatch.getNotificationSettings()
        FirebaseApp.configure()
        
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
        application.setMinimumBackgroundFetchInterval(1 * 60)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if AppSettings.currentAppUser is DatabaseHandler.Patient ||
            AppSettings.currentAppUser is DatabaseHandler.Family {
            registerDeviceForPatient()
        } else if AppSettings.currentAppUser is DatabaseHandler.Reader {
            registerDeviceForReader()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Log.d("Recieved notification")
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

    func registerDeviceForReader() {
        let ref = DatabaseHandler.database.child("NotificationCenter").child(AppSettings.currentPatient!)
        ref.child("Global").child("didUpdateJournal").observeSingleEvent(of: .value) { (snap) in
            if let hasUpdated = snap.value as? Bool {
                if hasUpdated {
                    NotificationDispatch.notifyCurrentUser(name: AppSettings.currentPatientName!, type: NotificationDispatch.NotificationType.NewJournalPost)
                }
            }
        }
    }
    
    func registerDeviceForPatient() {
        let ref = DatabaseHandler.database.child("NotificationCenter").child(AppSettings.currentPatient!)
        ref.child("Patient").observeSingleEvent(of: .value) { (snap) in
            if let items = snap.children.allObjects as? [DataSnapshot] {
                
                struct HHNotification {
                    let url: DatabaseReference
                    let name: String
                    let action: String
                }
                
                var notifications: [HHNotification] = []
                
                for item in items {
                    if let data = item.value as? [String: Any] {
                        let name = data["UserName"] as! String
                        let action = data["Action"] as! String
                        
                        let notification = HHNotification(url: item.ref, name: name, action: action)
                        
                        switch notification.action {
                        case "Commented on your Journal Post":
                            NotificationDispatch.notifyCurrentUser(name: name, type: NotificationDispatch.NotificationType.NewJournalComment)
                        case "Sent you encouragement":
                            NotificationDispatch.notifyCurrentUser(name: name, type: NotificationDispatch.NotificationType.NewEncouragementPost)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    

}

