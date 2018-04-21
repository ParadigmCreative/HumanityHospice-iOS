//
//  MenuHandler.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/19/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MenuHandler {
    static var staticMenu: MenuView?
    
    static func initialize(vc: UIViewController) {
        if let menu = Bundle.main.loadNibNamed("Menu", owner: vc, options: nil)?.first as? MenuView {
            staticMenu = menu
        }
    }
    
    static func openMenu(vc: UIViewController) {
        staticMenu?.setupTable()
        UIApplication.shared.keyWindow?.addSubview(staticMenu!)
        staticMenu?.frame = CGRect(x: 0 - UIScreen.main.bounds.width,
                                   y: 0,
                                   width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.height)
      
        
        UIView.animate(withDuration: 0.2, animations: {
            staticMenu?.frame = CGRect(x: 0,
                                       y: 0,
                                       width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.height)
        }) { (done) in
            staticMenu?.snp.removeConstraints()
            staticMenu!.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()

                staticMenu?.mainAreaView.snp.removeConstraints()
                staticMenu?.mainAreaView.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.bottom.equalToSuperview()
                    let width = UIScreen.main.bounds.width
                    make.width.equalTo(0.75 * width)
                })
            })

        }
        
        staticMenu?.mainAreaView.layer.shadowColor = UIColor.black.cgColor
        staticMenu?.mainAreaView.layer.shadowOffset = CGSize(width: 5, height: 2)
        staticMenu?.mainAreaView.layer.shadowOpacity = 0.5
        staticMenu?.mainAreaView.layer.shadowRadius = 5.0
        staticMenu?.mainAreaView.layer.masksToBounds = false
        
    }
    
    static func closeMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            staticMenu?.frame = CGRect(x: 0 - UIScreen.main.bounds.width,
                                       y: 0,
                                       width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.height)
        }) { (done) in
            staticMenu?.snp.removeConstraints()
            staticMenu?.removeFromSuperview()
        }
    }
    
}
