//
//  AppSettings.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import Firebase

class AppSettings {
    public static var currentFBUser: User?
    public static var currentAppUser: AppUser?
    public static var currentPatient: String?
    public static var currentPatientName: String?
    
    public static var signUpName: (first: String, last: String)?
    public static var userType: DatabaseHandler.UserType?
    
    public static func clearAppSettings() {
        currentFBUser = nil
        currentAppUser = nil
        signUpName = nil
        userType = nil
    }
}
