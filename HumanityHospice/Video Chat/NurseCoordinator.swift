////
//  NurseCoordinator.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import Foundation
import UIKit

class NurseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(nav: UINavigationController) {
        self.navigationController = nav
        nav.navigationBar.barTintColor = #colorLiteral(red: 0.4605029225, green: 0.447249949, blue: 0.7566576004, alpha: 1)
        
        nav.navigationBar.tintColor = .white
        
    }
    
    func start() {
        let vc = CallLogViewController.instantiate(from: "Nurse")
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func startVideo(sessionID: String, call: Call) {
        Log.d("Starting Video \(Date().timeIntervalSince1970)")
        let vc = VideoChatViewController.instantiate(from: "Nurse")
        vc.coordinator = self
        vc.call = call
        vc.sessionID = sessionID
        vc.uuid = UInt(bitPattern: UUID().hashValue)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
