//
//  AppDelegate.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/17/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
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
        print("Did Enter Background")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Did become Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("Will Terminate")
        closeConnections()

    }
    
    func closeConnections() {
        if let handle = DatabaseHandler.addedListenerHandle {
            Database.database().reference().removeObserver(withHandle: handle)
            print("Removed Journal Added Listener")
        }
        
        if let handle2 = DatabaseHandler.removedListenerHandle {
            Database.database().reference().removeObserver(withHandle: handle2)
            print("Removed Journal Removed Listener")
        }
        
        if let handle3 = DatabaseHandler.addedEBPostLister {
            Database.database().reference().removeObserver(withHandle: handle3)
            print("Removed Ecouragement Board Added Listener")
        }
        
        if let handle4 = DatabaseHandler.addedPhotoAlbumItem {
            Database.database().reference().removeObserver(withHandle: handle4)
            print("Removed Photo Album Added Listener")
        }
        
        if let handle5 = DatabaseHandler.changedListenerHandle {
            Database.database().reference().removeObserver(withHandle: handle5)
            print("Removed Post Comments Changed Listener")
        }
        
    }


}

