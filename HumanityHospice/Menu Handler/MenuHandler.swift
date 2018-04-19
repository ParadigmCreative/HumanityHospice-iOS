//
//  MenuHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit

class MenuHandler {
    var staticMenu: MenuView?
    
    static func openMenu(vc: UIViewController) {
        if let menu = Bundle.main.loadNibNamed("Menu", owner: vc, options: nil)?.first as? MenuView {
            vc.view.addSubview(menu)
        }
    }
    
    static func closeMenu(vc: UIViewController) {
        
    }
}
