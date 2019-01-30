////
//  CallLogViewController.swift
//  HealthApp
//
//  Created by App Center on 12/28/18.
//  Copyright © 2018 rlukedavis. All rights reserved.
//

import UIKit
import FirebaseAuth

class CallLogViewController: UIViewController, VideoCallDelegate, Storyboarded {

    let devMode: Bool = true
    var viewModel: CallLogViewModel!
    var videoChatDelegate: VideoChatDelegate!
    
    var videoChatController: VideoChatViewController?
    var coordinator: NurseCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VideoCallDatabaseHandler.set(delegate: self)
        viewModel = CallLogViewModel()
        callLogTable.delegate = self
        callLogTable.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.refreshCallLog {
            self.callLogTable.reloadData()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var callLogTable: UITableView!
    
    
    // MARK: - Actions
    @IBAction func openSettings(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Attention!", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Logout", style: .destructive, handler: { (action) in
            do {
                try Auth.auth().signOut()
                if let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "landingNav") as? UINavigationController {
                    RealmHandler.masterResetRealm()
                    self.present(nav, animated: true, completion: nil)
                }
            } catch {
                Log.e(error.localizedDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - VideoCallDelegate
    func goToVideo(sessionID: String, call: Call) {
        coordinator?.startVideo(sessionID: sessionID, call: call)
    }
    
    // MARK: - Navigation
    @IBAction func returnToCallLog(segue: UIStoryboardSegue) {
        VideoCallDatabaseHandler.endCall()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VideoChatViewController {
            if let data = sender as? (sessionID: String, call: Call) {
                vc.sessionID = data.sessionID
                vc.call = data.call
                vc.uuid = UInt(bitPattern: AppSettings.currentAppUser!.id.hashValue)
            }
        }
    }
    
}


extension CallLogViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.calls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = viewModel.calls[indexPath.row]
        
        cell.textLabel?.text = item.patientName
        cell.detailTextLabel?.text = viewModel.format(timeinterval: item.timestamp)
        cell.accessoryType = .disclosureIndicator
        
        switch item.status {
        case "missed":
            cell.textLabel?.textColor = .red
        case "recieved":
            cell.textLabel?.textColor = .black
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.calls[indexPath.row]
        Log.i("Clicked Cell: \(item.patientName)")
    }
}
