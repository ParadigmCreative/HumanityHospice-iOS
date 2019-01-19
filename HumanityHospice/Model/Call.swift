//
//  Call.swift
//  HumanityHospice
//
//  Created by App Center on 1/16/19.
//Copyright © 2019 Oklahoma State University. All rights reserved.
//

import Foundation
import RealmSwift

class Call: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var patientName: String = ""
    @objc dynamic var patientID: String = ""
    @objc dynamic var timestamp: TimeInterval = Date().timeIntervalSince1970
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
