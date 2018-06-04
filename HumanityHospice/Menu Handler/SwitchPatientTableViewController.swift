//
//  SwitchPatientTableViewController.swift
//  HumanityHospice
//
//  Created by App Center on 6/4/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class SwitchPatientTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        recieveNewPatientsFromDB()
        getPatientDataForListing()
        
    }

    // MARK: - Table view data source

    var patients: [DatabaseHandler.Patient] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    // MARK: - Get Patient Info for listings
    func getPatientDataForListing() {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            let patientIDs = reader.patients
            if patientIDs.count > 1 {
                for patientID in patientIDs {
                    DatabaseHandler.getPatientDetailsForReader(pid: patientID)
                }
            }
        }
    }
    
    func recieveNewPatientsFromDB() {
        NotificationCenter.default.addObserver(forName: .newPatientWasRecievedFromDB, object: nil, queue: .current) { (notification) in
            if let info = notification.userInfo {
                if let data = info as? [String: Any] {
                    if let user = data["user"] as? DatabaseHandler.Patient {
                        self.patients.append(user)
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
