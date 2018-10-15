//
//  EditProfileViewController.swift
//  Leaves
//
//  Created by Jay Patel on 11/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
//import Firebase
/*
//EditProfileID
class EditProfileViewController: UITableViewController, UITextFieldDelegate {

    var user:UserDetail?
    
    var userFieldList:[[Profiles]] = [[Profiles.Name],[Profiles.EmailAddress]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SaveTapped(_:)))
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user == nil {
            self.closeView()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        guard let cell = textField.superview?.superview as? ProfileTextFieldCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch userFieldList[indexPath.section][indexPath.row] {
        case .EmailAddress:
            user?.emailAddress = textField.text
            break
        case .Name:
            user?.UserName = textField.text
            break
        }
    }

    
    //Set Delegate
    @objc func SaveTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        guard isReachable else {
            self.popupAlertWithoutHandler(title: "Error", message: "No internet connect found", actionTitles: ["Ok"])
            return
        }
        
        if let userID = Auth.auth().currentUser?.uid {
            guard FirebaseActivity().UpdateUserInfo(userID: userID, user: user!) else {
                self.popupAlertWithoutHandler(title: "Error", message: "Unable to update details.", actionTitles: ["Okay"])
                return
            }
            _ = Utility.SaveUpdateUserInfo(userDetails: user!)
            self.closeView()
        }else{
            self.popupAlert(title: "Error", message: "No user found. Please login or try again for update details.", actionTitles: ["Okay"], actions: [{ ok in
                self.closeView()
            }])
        }
        
    }
    
    @objc func addImageTapped(sender:UIButton){
        //get From gallery or camera.. :D
    }
    
    func closeView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return userFieldList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFieldList[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //All Textfield
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileFieldID", for: indexPath) as! ProfileTextFieldCell
            cell.profileTextField.placeholder = userFieldList[indexPath.section][indexPath.row].rawValue
            cell.profileTextField.delegate = self
            
            switch userFieldList[indexPath.section][indexPath.row] {
            case .EmailAddress:
                cell.profileTextField.text = user?.emailAddress
                cell.profileTextField.isEnabled = false
                break
            case .Name:
                cell.profileTextField.text = user?.UserName
                cell.profileTextField.isEnabled = true
                break
            }
            return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
}
*/
