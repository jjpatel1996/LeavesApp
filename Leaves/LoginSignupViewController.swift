//
//  FirstPageViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreData

//AuthID
class LoginSignupViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    var signInButton: GIDSignInButton!
    
    var isPageOpenByPopup:Bool = false
    var delegate:NotifyDelegate?
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginSignupButton: UIButton!
    @IBOutlet weak var lsChangeSegment: UISegmentedControl!
    
    var firebaseActivity = FirebaseActivity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lsChangeSegment.selectedSegmentIndex = 0
        LoginSignupButton.setTitle("Log in", for: .normal)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        googleButton()
        if isPageOpenByPopup {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeView(sender:)))
        }
    }

    func googleButton(){
        
        signInButton = GIDSignInButton()
        signInButton.style = GIDSignInButtonStyle.standard
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([signInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),signInButton.topAnchor.constraint(equalTo: self.LoginSignupButton.bottomAnchor, constant: 15),signInButton.widthAnchor.constraint(equalToConstant: 230),
            signInButton.heightAnchor.constraint(equalToConstant: 48)])
        
    }
    
    @IBAction func LoginSignupDidChange(_ sender: Any) {
        if lsChangeSegment.selectedSegmentIndex == 0 {
            LoginSignupButton.setTitle("Log in", for: .normal)
        }else{
            LoginSignupButton.setTitle("Sign Up", for: .normal)
        }
    }
    
    @IBAction func LoginSignupPressed(_ sender: Any) {
       
        guard isReachable else {
            self.popupAlertWithoutHandler(title: "Error", message: "No internet connect found", actionTitles: ["Ok"])
            return
        }
        
        guard EmailTextField.text != nil && PasswordTextField.text != nil else {
            return
        }
        
        guard !EmailTextField.text!.isEmpty else {
            self.popupAlertWithoutHandler(title: "Error", message: "Email Address can't be empty", actionTitles: ["Ok"])
            return
        }
        
        guard !PasswordTextField.text!.isEmpty else {
            self.popupAlertWithoutHandler(title: "Error", message: "Password can't be empty", actionTitles: ["Ok"])
            return
        }
        
        let email = EmailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.StartloadingScreen()
        
        if lsChangeSegment.selectedSegmentIndex == 0 { //Login
          
            Auth.auth().signIn(withEmail: email, password: PasswordTextField.text!) { (user, error) in
                
                self.StoploadingScreen()
                if let error = error {
                    print(error.localizedDescription)
                    self.popupAlertWithoutHandler(title: "Error", message: error.localizedDescription, actionTitles: ["Ok"])
                    return
                }
                
                guard user != nil else {
                    self.popupAlertWithoutHandler(title: "Error", message: "User not found.", actionTitles: ["Ok"])
                    return
                }
                
                let userDetails = UserDetail(UserName: nil, emailAddress: email)
                self.firebaseActivity.insertUserFirebase(userID: user!.user.uid, user: userDetails)
                FirebaseActivity().UpdateTotalLeavesToFirebase()
                if Utility.SaveUpdateUserInfo(userDetails: userDetails) {
                    self.gotoLeaveVC()
                }else{
                    self.popupAlertWithoutHandler(title: "Error", message: "Something went wrong", actionTitles: ["Ok"])
                }
            }
       
        }else{
            
            Auth.auth().createUser(withEmail: email, password: PasswordTextField.text!) { (authResult, error) in
                
                self.StoploadingScreen()
                
                if let error = error {
                    print(error.localizedDescription)
                    self.popupAlertwithoutButton(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard authResult != nil else {
                    self.popupAlertwithoutButton(title: "Error", message: "Unable to get result.")
                    return
                }
                
                let userDetails =  UserDetail(UserName: nil, emailAddress: email)
                self.firebaseActivity.insertUserFirebase(userID: authResult!.user.uid, user: userDetails)
                if Utility.SaveUpdateUserInfo(userDetails: userDetails){
                    self.gotoLeaveVC()
                }else{
                    self.popupAlertwithoutButton(title: "Error", message: "Something went wrong")
                }
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
  
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print(user.profile.email)
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)

        print(credential.description)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                print(error.localizedDescription)
                return
            }

            let userDetails = UserDetail(UserName: user.profile.name, emailAddress: user.profile.email)
            self.firebaseActivity.insertUserFirebase(userID: authResult!.user.uid, user: userDetails)
            
            if Utility.SaveUpdateUserInfo(userDetails: userDetails) {
              self.gotoLeaveVC()
            }else{
                self.popupAlertwithoutButton(title: "Error", message: "Something went wrong")
            }
        }
        
    }

    func gotoLeaveVC(){
        LeavesHandler.SetSync(isOn: true)
        if isPageOpenByPopup {
            delegate?.notify()
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        let leaveVC = self.storyboard?.instantiateViewController(withIdentifier: "LeavesIDVC") as! LeavesViewController
        self.navigationController?.pushViewController(leaveVC, animated: true)
    }
    
    
    @objc func closeView(sender:UIBarButtonItem){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

    
}
