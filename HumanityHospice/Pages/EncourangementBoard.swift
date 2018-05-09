//
//  EncourangementBoard.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class EncourangementBoard: JournalTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenuHandler.staticMenu?.setHandingController(vc: self)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // newPostButton
    override func newPost(_ sender: Any) {
        
    }
    
    override func getPosts() {
        
    }
    
    
    

}
