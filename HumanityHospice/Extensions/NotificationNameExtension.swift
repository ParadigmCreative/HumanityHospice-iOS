//
//  NotificationNameExtension.swift
//  HumanityHospice
//
//  Created by App Center on 6/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let commentWasPosted = Notification.Name(rawValue: "commentWasPosted")
    static let newPatientWasRecievedFromDB = Notification.Name(rawValue: "newPatientWasRecievedFromDB")
    static let userSelectedNewPatient = Notification.Name(rawValue: "userSelectedNewPatient")
    static let ownerDidRequestDeleteImage = Notification.Name("ownerDidRequestDeleteImage")
}
