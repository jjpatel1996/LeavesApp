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

//AuthID
class LoginSignupViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    var signInButton: GIDSignInButton!
    
    var isPageOpenByPopup:Bool = false
    
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
       
        guard EmailTextField.text != nil && PasswordTextField != nil else {
            return
        }
        
        let email = EmailTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.StartloadingScreen()
        
        if lsChangeSegment.selectedSegmentIndex == 0 { //Login
          
            Auth.auth().signIn(withEmail: email, password: PasswordTextField.text!) { (user, error) in
                
                self.StoploadingScreen()
                if let error = error {
                    print(error.localizedDescription)
                    self.popupAlertwithoutButton(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard user != nil else {
                    self.popupAlertwithoutButton(title: "Error", message: "User not found.")
                    return
                }
                
                let userDetails = User(profileURL: nil, UserName: nil, emailAddress: email, ContactNo: nil)
                self.firebaseActivity.insertUserFirebase(userID: user!.user.uid, user: userDetails)
                FirebaseActivity().UpdateTotalLeavesToFirebase()
                self.gotoLeaveVC()
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
                
                let userDetails = User(profileURL: nil, UserName: nil, emailAddress: email, ContactNo: nil)
                self.firebaseActivity.insertUserFirebase(userID: authResult!.user.uid, user: userDetails)
                self.gotoLeaveVC()
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
            var imageURL:URL?
            if user.profile.hasImage {
                imageURL = user.profile.imageURL(withDimension: 100)
            }
            
            let userDetails = User(profileURL: imageURL?.absoluteString, UserName: user.profile.name, emailAddress: user.profile.email, ContactNo: nil)
            self.firebaseActivity.insertUserFirebase(userID: authResult!.user.uid, user: userDetails)
            self.gotoLeaveVC()
        }
        
    }

    func gotoLeaveVC(){
        if isPageOpenByPopup {
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
