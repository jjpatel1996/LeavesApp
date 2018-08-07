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
class LoginSignupViewController: UIViewController, GIDSignInUIDelegate {

    var signInButton: GIDSignInButton!
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    @IBOutlet weak var LoginSignupButton: UIButton!
    
    @IBOutlet weak var lsChangeSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lsChangeSegment.selectedSegmentIndex = 0
        LoginSignupButton.setTitle("Log in", for: .normal)
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()
        googleButton()
        
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
        
        if lsChangeSegment.selectedSegmentIndex == 0 { //Login
            Auth.auth().signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (user, error) in
                if let error = error {
                    // ...
                    print(error.localizedDescription)
                    return
                }
            }
        }else{ //SignUp
            Auth.auth().createUser(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (authResult, error) in
                if let error = error {
                    // ...
                    print(error.localizedDescription)
                    return
                }
            }
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                print(error.localizedDescription)
                return
            }
            let leaveVC = self.storyboard?.instantiateViewController(withIdentifier: "LeavesID") as! LeavesViewController
            self.navigationController?.pushViewController(leaveVC, animated: true)
            print("Just SignedIn")
            // User is signed in
            // ...
        }
        
    }
    
    //Sign Out
    /*
     let firebaseAuth = Auth.auth()
     do {
     try firebaseAuth.signOut()
     } catch let signOutError as NSError {
     print ("Error signing out: %@", signOutError)
     }
     
     */

    
    
}
