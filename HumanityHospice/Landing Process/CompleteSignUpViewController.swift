//
//  CompleteSignUpViewController.swift
//  HumanityHospice
//
//  Created by OSU App Center on 4/22/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class CompleteSignUpViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        masterSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Outlets
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var reenterPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var agreeToTermsButton: UIButton!
    @IBOutlet weak var patientCode: UITextField!
    @IBOutlet weak var termsTextView: UITextView!
    
    var inviteCode: String?
    var pidToFollow: String?
    var signupType: String = ""
    var nursePassword = "HumanityConnect2018"
    
    // MARK: - Setup
    func masterSetup() {
        setupButtons()
        setupTextfields()
        if signupType == "Patient" {
            patientCode.isEnabled = false
            patientCode.isHidden = true
            self.title = "I am a Patient"
        } else if signupType == "Friend" {
            self.title = "I am a Friend of a Patient"
        } else {
            patientCode.placeholder = "Admin Password"
            self.title = "Nurse Signup"
        }
        
        setupTextView()
        
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    func setupButtons() {
        signUpButton.setupMainButton()
        signUpButton.isEnabled = false
        agreeToTermsButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0, right: 0)
        agreeToTermsButton.layer.cornerRadius = 5
        agreeToTermsButton.layer.borderColor = UIColor.white.cgColor
        agreeToTermsButton.layer.borderWidth = 2
    }
    
    func setupTextfields() {
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        reenterPasswordTF.delegate = self
        patientCode.delegate = self
    }
    
    func setupTextView() {
        let terms = """
                    Privacy Policy

                    Effective date: June 25, 2018
                    Humanity Hospice, LLC ("us", "we", or "our") operates the website and the Humanity Connect mobile application (the "Service").
                    This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.
                    We use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy. Unless otherwise defined in this Privacy Policy, terms used in this Privacy Policy have the same meanings as in our Terms and Conditions.
                    Definitions:
                    Service
                    Service means the website and the Humanity Connect mobile application operated by Humanity Hospice, LLC
                    Personal Data
                    Personal Data means data about a living individual who can be identified from those data (or from those and other information either in our possession or likely to come into our possession).
                    Usage Data
                    Usage Data is data collected automatically either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).
                    Cookies
                    Cookies are small pieces of data stored on your device (computer or mobile device).
                    Information Collection and Use
                    We collect several different types of information for various purposes to provide and improve our Service to you.
                    Types of Data Collected
                    Personal Data
                    While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personally identifiable information may include, but is not limited to:
                    Email address
                    First name and last name
                    Phone number
                    Address, State, Province, ZIP/Postal code, City
                    Cookies and Usage Data
                    We may use your Personal Data to contact you with newsletters, marketing or promotional materials and other information that may be of interest to you. You may opt out of receiving any, or all, of these communications from us by following the unsubscribe link or instructions provided in any email we send.
                    Usage Data
                    We may also collect information that your browser sends whenever you visit our Service or when you access the Service by or through a mobile device ("Usage Data").
                    This Usage Data may include information such as your computer's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers and other diagnostic data.
                    When you access the Service by or through a mobile device, this Usage Data may include information such as the type of mobile device you use, your mobile device unique ID, the IP address of your mobile device, your mobile operating system, the type of mobile Internet browser you use, unique device identifiers and other diagnostic data.
                    Location Data
                    We may use and store information about your location if you give us permission to do so (“Location Data”). We use this data to provide features of our Service, to improve and customize our Service.
                    You can enable or disable location services when you use our Service at any time, through your device settings.
                    Tracking Cookies Data
                    We use cookies and similar tracking technologies to track the activity on our Service and hold certain information.
                    Cookies are files with small amount of data which may include an anonymous unique identifier. Cookies are sent to your browser from a website and stored on your device. Tracking technologies also used are beacons, tags, and scripts to collect and track information and to improve and analyze our Service.
                    You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our Service.
                    Examples of Cookies we use:
                    Session Cookies. We use Session Cookies to operate our Service.
                    Preference Cookies. We use Preference Cookies to remember your preferences and various settings.
                    Security Cookies. We use Security Cookies for security purposes.
                    Use of Data
                    Humanity Hospice, LLC uses the collected data for various purposes:
                    To provide and maintain our Service
                    To notify you about changes to our Service
                    To allow you to participate in interactive features of our Service when you choose to do so
                    To provide customer support
                    To gather analysis or valuable information so that we can improve our Service
                    To monitor the usage of our Service
                    To detect, prevent and address technical issues
                    To provide you with news, special offers and general information about other goods, services and events which we offer that are similar to those that you have already purchased or enquired about unless you have opted not to receive such information
                    Transfer of Data
                    Your information, including Personal Data, may be transferred to — and maintained on — computers located outside of your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from your jurisdiction.
                    If you are located outside and choose to provide information to us, please note that we transfer the data, including Personal Data, to and process it there.
                    Your consent to this Privacy Policy followed by your submission of such information represents your agreement to that transfer.
                    Humanity Hospice, LLC will take all steps reasonably necessary to ensure that your data is treated securely and in accordance with this Privacy Policy and no transfer of your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of your data and other personal information.
                    Disclosure of Data
                    Business Transaction
                    If Humanity Hospice, LLC is involved in a merger, acquisition or asset sale, your Personal Data may be transferred. We will provide notice before your Personal Data is transferred and becomes subject to a different Privacy Policy.
                    Disclosure for Law Enforcement
                    Under certain circumstances, Humanity Hospice, LLC may be required to disclose your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).
                    Legal Requirements
                    Humanity Hospice, LLC may disclose your Personal Data in the good faith belief that such action is necessary to:
                    To comply with a legal obligation
                    To protect and defend the rights or property of Humanity Hospice, LLC
                    To prevent or investigate possible wrongdoing in connection with the Service
                    To protect the personal safety of users of the Service or the public
                    To protect against legal liability
                    Security of Data
                    The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.
                    Service Providers
                    We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used.
                    These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.
                    Analytics
                    We may use third-party Service Providers to monitor and analyze the use of our Service.
                    Google Analytics
                    Google Analytics is a web analytics service offered by Google that tracks and reports website traffic. Google uses the data collected to track and monitor the use of our Service. This data is shared with other Google services. Google may use the collected data to contextualize and personalize the ads of its own advertising network.
                    For more information on the privacy practices of Google, please visit the Google Privacy Terms web page: https://policies.google.com/privacy?hl=en
                    Links to Other Sites
                    Our Service may contain links to other sites that are not operated by us. If you click on a third party link, you will be directed to that third party's site. We strongly advise you to review the Privacy Policy of every site you visit.
                    We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.
                    Children's Privacy
                    Our Service does not address anyone under the age of 18 ("Children").
                    We do not knowingly collect personally identifiable information from anyone under the age of 18. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.
                    Changes to This Privacy Policy
                    We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
                    We will let you know via email and/or a prominent notice on our Service, prior to the change becoming effective and update the "effective date" at the top of this Privacy Policy.
                    You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.
                    Contact Us
                    If you have any questions about this Privacy Policy, please contact us:
                    By email: Info@humanityhospice.com
                    By visiting this page on our website: Www.humanityhospice.com
                    By phone number: 405.418.2530


                    """
        
        self.termsTextView.text = terms
    }
    
    // MARK: - Actions
    @IBAction func agreeToTerms(_ sender: Any) {
        if agreeToTermsButton.isSelected {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox"), for: .normal)
            agreeToTermsButton.isSelected = false
            signUpButton.isEnabled = false
        } else {
            agreeToTermsButton.setImage(#imageLiteral(resourceName: "CheckBox Filled"), for: .normal)
            agreeToTermsButton.isSelected = true
            signUpButton.isEnabled = true
        }
    }

    
    @IBAction func signUp(_ sender: Any) {
        self.showIndicator()
        verifyTextFields { (first, last, email, pass) in

            if !patientCode.isHidden {
                if signupType == "Friend" {
                    guard let invite = patientCode.text else { return }
                    validateInvite(code: invite, completion: { (pid) in
                        self.createUser(first: first, last: last, email: email, password: pass)
                    })
                } else {
                    guard let password = patientCode.text else { return }
                    guard password == nursePassword.uppercased() else {
                        self.closeIndicator()
                        showAlert(title: "Hmmm...", message: "Incorrect Password")
                        return
                    }
                    
                    self.createNurse(first: first, last: last, email: email, pass: pass, completion: {
                        guard VideoCallDatabaseHandler.deviceToken.isEmpty == false else { return }
                        CallManager.goOnline(with: VideoCallDatabaseHandler.deviceToken)
                        
                        let nav = UINavigationController()
                        self.present(nav, animated: true, completion: nil)
                        let nurseCoordinator = NurseCoordinator(nav: nav)
                        nurseCoordinator.start()
                    })
                }
            } else {
                self.createUser(first: first, last: last, email: email, password: pass)
            }
        }
    }
    
    
    func moveToJournal() {
        if let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController {
           self.present(tabbar, animated: true, completion: nil)
        }
    }
    
    func moveToNurseWaiting() {
        if let nav = UIStoryboard(name: "Nurse", bundle: nil).instantiateViewController(withIdentifier: "NurseNav") as? UINavigationController {
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - Textfield
    func verifyTextFields(completion: (_ first: String, _ last: String, _ email: String, _ password: String)->()) {
        
        if let f = firstNameTF.text, let l = lastNameTF.text, let e = emailTF.text, let p1 = passwordTF.text, let p2 = reenterPasswordTF.text {
            
            guard f.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your first name")
                Utilities.closeActivityIndicator()
                return
            }
            
            guard l.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your last name")
                Utilities.closeActivityIndicator()
                return
            }
            
            guard e.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter a valid email address.")
                Utilities.closeActivityIndicator()
                return
            }
            
            guard p1.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please enter your password.")
                Utilities.closeActivityIndicator()
                return
            }
            
            guard p2.isEmpty == false else {
                self.showAlert(title: "Oops!", message: "Please re-enter your password.")
                Utilities.closeActivityIndicator()
                return
            }
            
            if p1 == p2 {
                completion(f, l, e, p1)
            } else {
                Utilities.closeActivityIndicator()
                self.showAlert(title: "Oops!", message: "Passwords do not match.")
            }
            
        }
        
    }
    
    func validateInvite(code: String, completion: @escaping (String)->()) {
        Utilities.showActivityIndicator(view: self.view)
        // Query DB
        DatabaseHandler.checkDBForInviteCode(code: code) { (success, pid) in
            Utilities.closeActivityIndicator()
            if success {
                if let pid = pid {
                    AppSettings.currentPatient = pid
                    self.pidToFollow = pid
                    completion(pid)
                }
            } else {
                // show failure
                self.showAlert(title: "Hmm...", message: "That invite code doesn't exist.")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF {
            lastNameTF.becomeFirstResponder()
        } else if textField == lastNameTF {
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            reenterPasswordTF.becomeFirstResponder()
        } else if textField == reenterPasswordTF {
            if patientCode.isHidden {
                textField.resignFirstResponder()
            } else {
                patientCode.becomeFirstResponder()
            }
        } else if textField == patientCode {
            textField.resignFirstResponder()
        }
        
        return true
    }

    

}


extension CompleteSignUpViewController {
    func createUser(first: String, last: String, email: String, password: String) {
        // Sign up user
        DatabaseHandler.signUp(email: email, password: password, completion: { (user, error) in
            if error != nil {
                // show alert if error isn't nil
                self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                self.closeIndicator()
            } else {
                if user != nil {
                    // set current user to user handed back from call
                    AppSettings.currentFBUser = user
                    AppSettings.signUpName = (first, last)
                    
                    // make profile changes to user
                    self.submitChanges(user: user, first: first, last: last)
                    
                } else {
                    self.closeIndicator()
                    self.showAlert(title: "Hmm...", message: "Something happend. Please try again later")
                }
            }
        })
    }
    
    func createNurse(first: String, last: String, email: String, pass: String, completion: @escaping ()->()) {
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
            guard error == nil else {
                Log.e(error!.localizedDescription)
                self.closeIndicator()
                self.showAlert(title: "Hmmm...", message: error!.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                self.closeIndicator()
                self.showAlert(title: "Something went wrong...", message: "Please try again later.")
                return
            }
            
            AppSettings.signUpName = (first, last)
            
            let changes = user.createProfileChangeRequest()
            changes.displayName = "\(first) \(last)"
            changes.commitChanges(completion: { (error) in
                guard error == nil else {
                    Log.e(error!.localizedDescription)
                    self.closeIndicator()
                    self.showAlert(title: "Hmmm...", message: error!.localizedDescription)
                    return
                }
                
                Log.d("New User:", user.uid, user.email!, user.displayName!)
                
                // create app user instance
                guard let appuser = DatabaseHandler.createAppUser(user: user) else {
                    Log.e("Could not get app user from user object")
                    return
                }
                
                let data: [String: Any] = ["firstName": first,
                                           "lastName": last,
                                           "FacetimeID": email,
                                           "HangoutID": email,
                                           "isOnCall": false,
                                           "Team": "Edmond",
                                           "id": user.uid]
                
                let userRef = DatabaseHandler.database.child("Staff").child(user.uid)
                userRef.setValue(data, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        Log.e(error!.localizedDescription)
                    } else {
                        AppSettings.currentAppUser = appuser
                        completion()
                    }
                })
            })
            
        }
    }
    
    func submitChanges(user: User?, first: String, last: String) {
        let changes = user?.createProfileChangeRequest()
        changes?.displayName = "\(first) \(last)"
        changes?.commitChanges(completion: { (error) in
            if error != nil {
                // show alert if there was an error
                self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                self.closeIndicator()
            } else {
                Log.d("New User:", user!.uid, user!.email!, user!.displayName!)
                
                // create app user instance
                let appuser = DatabaseHandler.createAppUser(user: user!)
                
                self.createDatabaseReferenceFor(appuser: appuser, user: user)
            
            }
        })
    }
    
    func createDatabaseReferenceFor(appuser: AppUser?, user: User?) {
        // create DB reference with user data
        DatabaseHandler.createUserReference(type: AppSettings.userType!, user: appuser!, completion: { (error, done) in
            if error != nil {
                self.showAlert(title: "Hmm...", message: error!.localizedDescription)
                self.closeIndicator()
            } else {
                Log.d("Created new user:", appuser!.firstName, appuser!.lastName)
                
                // SET CURRENT PATIENT
                if AppSettings.userType == DatabaseHandler.UserType.Reader {
                    if let id = self.pidToFollow {
                        DatabaseHandler.addUserToFollow(pid: id, userID: appuser!.id)
                        DatabaseHandler.addReaderToPatientList(pid: id, rid: appuser!.id)
                        AppSettings.currentPatient = id
                        if var user = appuser as? DatabaseHandler.Reader {
                            user.readingFrom = id
                            AppSettings.currentAppUser = user
                        }
                        Log.d("Set currentPatient to:", id)
                    }
                } else if AppSettings.userType == DatabaseHandler.UserType.Patient {
                    AppSettings.currentPatient = AppSettings.currentFBUser!.uid
                    
                    // make first post
                    DatabaseHandler.postToDatabase(posterUID: user!.uid,
                                                   posterName: user!.displayName!,
                                                   message: "\(user!.displayName!) has joined Humanity Hospice",
                                                   imageURL: nil,
                                                   imageName: nil,
                                                   completion: {})
                } else if AppSettings.userType == DatabaseHandler.UserType.Staff {
                    AppSettings.currentPatient = nil
                }
                
                // if creation is successful, set
                AppSettings.currentAppUser = appuser
                
                self.closeIndicator()
                
                if AppSettings.userType != DatabaseHandler.UserType.Staff {
                    self.moveToJournal()
                } else {
                    guard VideoCallDatabaseHandler.deviceToken.isEmpty == false else { return }
                    CallManager.goOnline(with: VideoCallDatabaseHandler.deviceToken)
                    
                    let nav = UINavigationController()
                    self.present(nav, animated: true, completion: nil)
                    let nurseCoordinator = NurseCoordinator(nav: nav)
                    nurseCoordinator.start()
                }
                
            }
        })
        
    }
    
}
