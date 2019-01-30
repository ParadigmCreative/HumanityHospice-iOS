////
//  Storyboarded.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate(from storyboardName: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(from storyboardName: String) -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)
        
        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]
        
        // load our storyboard
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
