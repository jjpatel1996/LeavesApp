//
//  SettingViewController.swift
//  Leaves
//
//  Created by Jay Patel on 11/08/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

enum SettingType:String {
    case Profile = "Profile"
    case Sync = "Sync data to server"
    case Logout = "Logout from device"
    case EditLeave = "Add/Edit total and remain leaves"
    case LoginSignUp = "Login/Signup" //Show LoginSignUp VC By Popup
}

enum EditLeaveType {
    case TotalWorkingLeaves
    case TotalSickLeaves
    case RemainSickLeaves
    case RemainWorkingLeaves
}

enum Profiles {
    case EmailAddress
    case Name
    case ContactNo
     case ProfileImage
}

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var SettingTableView: UITableView!
    
    var settingSections = [SettingType]()
    var leaveCells:[EditLeaveType] = [.TotalWorkingLeaves,.RemainWorkingLeaves,.TotalSickLeaves,.RemainSickLeaves]
    var profilesCells:[Profiles] = [.ProfileImage,.EmailAddress,.Name,.ContactNo]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingTableView.delegate = self
        SettingTableView.dataSource = self
        
        settingSections.append(SettingType.EditLeave)
        settingSections.append(SettingType.Sync)
        
        if Auth.auth().currentUser != nil {
            settingSections.insert(SettingType.Profile, at: 0)
            settingSections.append(SettingType.Logout)
        } else {
            settingSections.append(SettingType.LoginSignUp)
        }
        
    }

    var isFirstTime:Bool = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstTime {
            isFirstTime = false
        }else{
            self.SettingTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if settingSections[section] == .EditLeave {
            return leaveCells.count
        }else if settingSections[section] == .Profile {
            return profilesCells.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch settingSections[indexPath.section] {
        case .EditLeave:
            return setupLeaveEditCell(indexPath: indexPath)
        case .Sync:
            return setupSyncCell(indexPath: indexPath)
        case .Profile:
            return setupProfileCell(indexPath: indexPath)
        case .LoginSignUp:
            return setupLoginSignupCell(indexPath: indexPath)
        default:
            return setupLogoutCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if settingSections[indexPath.section] == .LoginSignUp {
             let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthID") as! LoginSignupViewController
            loginVC.isPageOpenByPopup = true
            self.present( UINavigationController(rootViewController: loginVC), animated: true, completion: nil)
        }
    }
    
    func setupLoginSignupCell(indexPath:IndexPath) -> UITableViewCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "LoginSignUp", for: indexPath)
        cell.textLabel?.text = "Login or Signup"
        return cell
    }
    
    func setupLogoutCell(indexPath:IndexPath) -> LogoutCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "LogoutID", for: indexPath) as! LogoutCell
        cell.LogoutButton.addTarget(self, action: #selector(logout(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func logout(sender:UIButton){
        
        //Check Internet Connection
        
        self.popupAlert(title: "Logou", message: "Are you sure want to logout?", actionTitles: ["Log out","Cancel"], actions: [
            {  logout in
                
                self.FirebaseLogout()
                
            }, { cancel in return }
            ])
    }
    
    func FirebaseLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //Where to go
            
        } catch let signOutError as NSError {
            self.popupAlertwithoutButton(title: "Error", message: "Unable to logout. Please try again after sometime.")
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func setupProfileCell(indexPath:IndexPath) -> ProfileCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "ProfileID", for: indexPath) as! ProfileCell
        cell.ProfileImage.image = #imageLiteral(resourceName: "UserProfile")
        //get From Online?
        return cell
    }
    
    func setupSyncCell(indexPath:IndexPath) -> SyncCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "SyncID", for: indexPath) as! SyncCell
        cell.ActivityIndicator.isHidden = true
        cell.Switch.isOn = LeavesHandler.isSyncON()
        cell.Switch.addTarget(self, action: #selector(switchTapped(sender:)), for: UIControlEvents.editingChanged)
        return cell
    }
    
    @objc func switchTapped(sender:UISwitch){
        if sender.isOn {
            LeavesHandler.SetSync(isOn: true)
            //Sync Data
            guard let cell = sender.superview?.superview as? SyncCell else {
                return
            }
            cell.ActivityIndicator.isHidden = false
            cell.ActivityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                cell.ActivityIndicator.stopAnimating()
                cell.ActivityIndicator.isHidden = true
            }
            
        }else{
            LeavesHandler.SetSync(isOn: false)
        }
    }
    
    func setupLeaveEditCell(indexPath:IndexPath) -> LeaveEditingCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "LeaveEditID", for: indexPath) as! LeaveEditingCell
        var leaveTitle:String!
        var leaveValue:Int!
        
        switch leaveCells[indexPath.row] {
        case .RemainSickLeaves:
               leaveTitle = "Remain Sick Leaves"
               leaveValue = LeavesHandler.getRemainSickLeaves()
               break
        case .RemainWorkingLeaves:
                leaveTitle = "Remain Working Leaves"
                leaveValue = LeavesHandler.getRemainWorkingLeaves()
                break
        case .TotalWorkingLeaves:
                 leaveTitle = "Total Working Leaves"
                leaveValue = LeavesHandler.getWorkingLeaves()
                break
        case .TotalSickLeaves:
                leaveTitle = "Total Sick Leaves"
                leaveValue = LeavesHandler.getSickLeaves()
                break
        }
        cell.LeaveTitle.text = leaveTitle
        cell.LeaveEditTextfield.text = String(leaveValue)
        return cell
    }
    
}
