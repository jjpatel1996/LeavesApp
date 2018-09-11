//
//  EditProfileViewController.swift
//  Leaves
//
//  Created by Jay Patel on 11/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import Firebase

//EditProfileID
class EditProfileViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var ProfileView: UIImageView!
    
    @IBOutlet weak var UserNameTextfield: UITextField!
    @IBOutlet weak var EmailAddressTextfield: UITextField!
    @IBOutlet weak var PhoneNumberTextfield: UITextField!
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailAddressTextfield.isEnabled = false
        UserNameTextfield.delegate = self
        PhoneNumberTextfield.delegate = self
        EmailAddressTextfield.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user != nil {
            UserNameTextfield.text = user?.UserName
            EmailAddressTextfield.text = user?.emailAddress
            PhoneNumberTextfield.text = user?.ContactNo
        }else{
            self.closeView()
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == UserNameTextfield {
            user?.UserName = UserNameTextfield.text
        }else if textField == EmailAddressTextfield {
            user?.emailAddress = EmailAddressTextfield.text
        }else if textField == PhoneNumberTextfield {
            user?.ContactNo = PhoneNumberTextfield.text
        }
    }

    
    //Set Delegate
    @IBAction func SaveTapped(_ sender: Any) {
     
        //Check Internet Connect First.
        
        if let userID = Auth.auth().currentUser?.uid {
            FirebaseActivity().UpdateUserInfo(userID: userID, user: user!)
            self.closeView()
        }else{
            self.popupAlert(title: "Error", message: "No user found. Please login or try again for update details.", actionTitles: ["Okay"], actions: [{ ok in
                self.closeView()
                }])
        }
        
    }
    
    @IBAction func CloseView(_ sender: Any) {
       closeView()
    }
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
