//
//  SwitchPatientTableViewController.swift
//  HumanityHospice
//
//  Created by App Center on 6/4/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit

class SwitchPatientTableViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        recieveNewPatientsFromDB()
        getPatientDataForListing()
        setupNavigaitonController()
        setupTableView()
        inviteCodeTF.delegate = self
        
    }

    // MARK: - Navigation Controller
    func setupNavigaitonController() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        cancelButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPatient))
        addButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addPatient() {
        self.view.addSubview(addPatientPopUp)
        let center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        addPatientPopUp.center = center
        addPatientPopUp.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        addPatientPopUp.layer.cornerRadius = 5
        
        submitCodeButton.layer.cornerRadius = 5
        
        UIView.animate(withDuration: 0.3) {
            self.addPatientPopUp.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - Add Patient View
    @IBOutlet var addPatientPopUp: InviteCodePopUp!
    @IBOutlet weak var inviteCodeTF: UITextField!
    @IBOutlet weak var submitCodeButton: UIButton!
    @IBAction func submitCode(_ sender: UIButton) {
        startDataCheck()
    }
    
    func closePopupView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.addPatientPopUp.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (done) in
            self.addPatientPopUp.removeFromSuperview()
        }
    }
    
    
    // MARK: - Table view data source

    var patients: [DatabaseHandler.Patient] = []
    
    func setupTableView() {
        self.title = "Switch Users"
        self.tableView.register(ChangePatientCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return patients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChangePatientCell

        if patients.count > 0 {
            cell.patient = patients[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newPatient = patients[indexPath.row]
        let currentPatient = AppSettings.currentPatientName!
        if newPatient.fullName() == currentPatient {
            showAlert(title: "Oops!", message: "You are already following \(currentPatient)!")
        } else {
            showConfirmAlert(title: "Warning!", message: "Selecting 'Switch' will change the patient you are currently viewing. Are you sure you want to switch from \(currentPatient) to \(newPatient.fullName())?", patient: newPatient)
        }
        
    }

    // MARK: - Get Patient Info for listings
    var totalPatientsToGrab = 0
    func getPatientDataForListing() {
        if let reader = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            let patientIDs = reader.patients
            if patientIDs.count > 0 {
                self.totalPatientsToGrab = patientIDs.count
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
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Add Patient Process
    func startDataCheck() {
        if let code = inviteCodeTF.text {
            guard code.count == 6 else {
                showAlert(title: "Hmm...", message: "Please enter a valid 6 digit code.")
                return
            }
            
            DatabaseHandler.checkDBForInviteCode(code: code) { (isValid, patientID) in
                if isValid {
                    if let uid = patientID {
                        // A user with this ID exists, so we need to get the data about this person from the DB
                        // Create a user object, and add it to the current readers list of people
                        // After data is grabbed update the list
                        DatabaseHandler.getPatientDetailsForFamilyMember(pid: uid, completion: { (patient) in
                            if var currentUser = AppSettings.currentAppUser as? DatabaseHandler.Reader {
                                let name = patient.fullName()
                                currentUser.patients.append(name)
                                AppSettings.currentAppUser = currentUser
                                self.patients.append(patient)
                                self.tableView.reloadData()
                                self.closePopupView()
                            }
                        })
                        
                        DatabaseHandler.addUserToFollow(pid: uid, userID: AppSettings.currentFBUser!.uid)
                        
                    }
                } else {
                    // Show invalid alert
                    self.showAlert(title: "Hmm...", message: "That code doesn't exist.")
                }
            }
            
        }
    }
    
    // MARK: Showing Alerts
    func showConfirmAlert(title: String, message: String, patient: DatabaseHandler.Patient) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let switchUser = UIAlertAction(title: "Switch", style: .destructive) { (alert) in
            print("Switching Users...")
            self.switchPatient(patient: patient)
        }
        
        alert.addAction(cancel)
        alert.addAction(switchUser)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func switchPatient(patient: DatabaseHandler.Patient) {
        // Clear all current data
        RealmHandler.masterResetRealm()
        DatabaseHandler.closeConnections()
        
        // get new data
        AppSettings.currentPatient = patient.id
        AppSettings.currentPatientName = patient.fullName()
        if var user = AppSettings.currentAppUser as? DatabaseHandler.Reader {
            user.readingFrom = patient.id
            AppSettings.currentAppUser = user
            DatabaseHandler.setCurrentPatientToReadFrom(patientID: patient.id, followerID: user.id)
        }
        
        // close view
        self.dismiss(animated: true, completion: {
            MenuHandler.closeMenu()
            NotificationCenter.default.post(name: .userSelectedNewPatient, object: nil)
        })
    }
    
    
    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == inviteCodeTF {
            textField.resignFirstResponder()
        }
        
        return true
    }

}

class ChangePatientCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var patient: DatabaseHandler.Patient! {
        didSet {
            self.textLabel?.text = patient.fullName()
        }
    }
}




