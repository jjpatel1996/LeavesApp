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
import CoreData


enum SettingType:String {
    case Profile = "Profile"
    case Sync = "Sync data online"
    case Logout = ""
    case EditLeave = "Total and remain leaves"
    case LoginSignUp = "Login/Signup" //Show LoginSignUp VC By Popup
}

enum Profiles :String {
    case EmailAddress = "Email Address"
    case Name = "Name"
}

struct UserDetail {
    var UserName:String?
    var emailAddress:String?
}

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotifyDelegate {

    @IBOutlet weak var SettingTableView: UITableView!
    
    var settingSections = [SettingType]()
    var leaveCells:[EditLeaveType] = [.TotalWorkingLeaves,.RemainWorkingLeaves,.TotalSickLeaves,.RemainSickLeaves]
    var profilesCellHeights:[CGFloat] = [UITableView.automaticDimension,UITableView.automaticDimension,UITableView.automaticDimension]
    var heightsForCells = [CGFloat]()
    
    let ref = Database.database().reference()
    let fA = FirebaseActivity.init()
    
    var userProfile:UserDetail? {
        didSet {
            if let index = settingSections.index(of: SettingType.Profile){
                SettingTableView.reloadSections(IndexSet(integer: index), with: .fade)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        setup()
        
    }

    func setup(){
        SettingTableView.delegate = self
        SettingTableView.dataSource = self
        SettingTableView.tableFooterView = UIView()
        SettingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LoginSignUp")
        SettingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserDetails")
        SettingTableView.register(UINib(nibName: "ProfileHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ProfileSectionHeader")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeView))
    }
    
    func setupSections(){
        settingSections.removeAll()
//        settingSections.append(SettingType.EditLeave)
        settingSections.append(SettingType.Sync)
        
        if Auth.auth().currentUser != nil {
            settingSections.insert(SettingType.Profile, at: 0)
            settingSections.append(SettingType.Logout)
        } else {
            settingSections.append(SettingType.LoginSignUp)
        }
        SettingTableView.reloadData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSections()
        if Auth.auth().currentUser?.uid != nil {
           getUserDetails()
        }
    }
    
    func getUserDetails(){ //Offline Fetch
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let fetchedResults = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            guard fetchedResults.count > 0 else { self.loadUserProfile(); return }
            let userObject: User = fetchedResults[0]
            self.userProfile = UserDetail(UserName: userObject.name, emailAddress: userObject.email)
            
        } catch let error as NSError {
            print(error.description)
            loadUserProfile()
        }
    }
    
    func loadUserProfile(){ //Online Fetch
        
        if let uid = Auth.auth().currentUser?.uid {
            ref.child(LeaveTableNames.User.rawValue).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let firstName = value?["FirstName"] as? String
                //let lastName = value?["LastName"] as? String
                //let isVerified = value?["isVerified"] as? Bool
                let emailAddress = value?["Email"] as? String
                self.userProfile = UserDetail(UserName: firstName, emailAddress: emailAddress)
                
            }) { (error) in
                print(error.localizedDescription)
                //Not Found
            }
        }
    }
    
    func notify() {
        syncData()
    }
    
    func syncData(){
        fA.syncAllLeavesToDB()
        fA.syncTotalLeaveFromFirebaseToApp(completion: nil)
        fA.syncLeavesFromFirebaseToApp()
    }
    
    @objc func closeView(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if settingSections[section] == .EditLeave {
            return leaveCells.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if settingSections[section] == .Profile {
            let header = ProfileHeader(user: self.userProfile, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            return header
        }else{
           return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section] != .Profile ? settingSections[section].rawValue : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch settingSections[indexPath.section] {
        case .EditLeave:
            return setupLeaveEditCell(indexPath: indexPath)
        case .Sync:
            return setupSyncCell(indexPath: indexPath)
        case .Profile:
            return setupUserDetailsCell(indexPath: indexPath)
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
            loginVC.delegate = self
            self.present( UINavigationController(rootViewController: loginVC), animated: true, completion: nil)
        }else if settingSections[indexPath.section] == .Profile {
            if self.userProfile != nil {
                let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileID") as! EditProfileViewController
                editProfileVC.user = self.userProfile
                self.navigationController?.pushViewController(editProfileVC, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if settingSections[section] == .Profile {
            return  CGFloat(100)
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func setupLoginSignupCell(indexPath:IndexPath) -> UITableViewCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "LoginSignUp", for: indexPath)
        cell.textLabel?.text = "Login or Signup"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor.blueButtonColor()
        return cell
    }
    
    func setupLogoutCell(indexPath:IndexPath) -> LogoutCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "LogoutID", for: indexPath) as! LogoutCell
        cell.LogoutButton.addTarget(self, action: #selector(logout(sender:)), for: .touchUpInside)
        return cell
    }
    
    func setupUserDetailsCell(indexPath:IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "UserDetails")
        cell.textLabel?.text = "Edit Profile"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func setupSyncCell(indexPath:IndexPath) -> SyncCell {
        
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "SyncID", for: indexPath) as! SyncCell
        cell.ActivityIndicator.isHidden = true
     
        let isEnable = Auth.auth().currentUser != nil
        cell.Switch.isEnabled = isEnable
        cell.Switch.isOn = isEnable ? LeavesHandler.isSyncON() : false
        cell.Switch.addTarget(self, action: #selector(switchTapped(sender:)), for: UIControl.Event.valueChanged)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func switchTapped(sender:UISwitch){
        
        if sender.isOn {
          
            LeavesHandler.SetSync(isOn: true)
            syncData()
            guard let cell = sender.superview?.superview as? SyncCell else {
                return
            }
            cell.Switch.isHidden = true
            cell.ActivityIndicator.isHidden = false
            cell.ActivityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                cell.ActivityIndicator.stopAnimating()
                cell.ActivityIndicator.isHidden = true
                cell.Switch.isHidden = false
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
        cell.selectionStyle = .none
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
            DispatchQueue.main.async {
                self.setupSections()
            }
        } catch let signOutError as NSError {
            self.popupAlertwithoutButton(title: "Error", message: "Unable to logout. Please try again after sometime.")
            print ("Error signing out: %@", signOutError)
        }
    }
    
}


