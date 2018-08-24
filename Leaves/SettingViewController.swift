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
    case Sync = "Sync data online"
    case Logout = "Logout from device"
    case EditLeave = "Total and remain leaves"
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

struct User {
    var profileURL:String?
    var UserName:String?
    var emailAddress:String?
    var ContactNo:String?
}

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var SettingTableView: UITableView!
    
    var settingSections = [SettingType]()
    var leaveCells:[EditLeaveType] = [.TotalWorkingLeaves,.RemainWorkingLeaves,.TotalSickLeaves,.RemainSickLeaves]
    var profilesCells:[Profiles] = [.ProfileImage,.EmailAddress,.ContactNo]
    var profilesCellHeights:[CGFloat] = [UITableViewAutomaticDimension,UITableViewAutomaticDimension,UITableViewAutomaticDimension]
    var heightsForCells = [CGFloat]()
    
    let ref = Database.database().reference()
   
    var userProfile:User? {
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeView))
    }
    
    func setupSections(){
        settingSections.removeAll()
        heightsForCells.removeAll()
        settingSections.append(SettingType.EditLeave)
        heightsForCells.append(50)
        settingSections.append(SettingType.Sync)
        heightsForCells.append(50)
        
        if Auth.auth().currentUser != nil {
            settingSections.insert(SettingType.Profile, at: 0)
            heightsForCells.insert(120, at: 0)
            settingSections.append(SettingType.Logout)
            heightsForCells.append(50)
        } else {
            settingSections.append(SettingType.LoginSignUp)
            heightsForCells.append(50)
        }
        SettingTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSections()
        loadUserProfile()
        //Load Contact Details And Set it when availble
    }
    
    func loadUserProfile(){
        //isVerified
        if let uid = Auth.auth().currentUser?.uid {
            ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let userProfileURL = value?["ProfileURL"] as? String
                let firstName = value?["FirstName"] as? String
                //let lastName = value?["LastName"] as? String
                //let isVerified = value?["isVerified"] as? Bool
                let emailAddress = value?["Email"] as? String
                let ContactNo = value?["ContactNo"] as? String
                self.userProfile = User(profileURL: userProfileURL, UserName: firstName, emailAddress: emailAddress, ContactNo: ContactNo)
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    
    @objc func closeView(){
        self.navigationController?.dismiss(animated: true, completion: nil)
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
            //profilesCells.count
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
            //return profilesCells[indexPath.row] == .ProfileImage ? setupProfileCell(indexPath: indexPath) : setupUserDetailsCell(indexPath: indexPath)
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
            self.present( UINavigationController(rootViewController: loginVC), animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        return settingSections[indexPath.section] == .Profile ? profilesCellHeights[indexPath.row] : heightsForCells[indexPath.section]
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
        
        var cell:UITableViewCell!
        
        switch profilesCells[indexPath.row] {
        case .ContactNo:
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "UserDetails")
            cell.textLabel?.text = "Phone number"
            cell.detailTextLabel?.text = userProfile?.ContactNo ?? "Not added"
            break
        case .EmailAddress:
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "UserDetails")
            cell.textLabel?.text = userProfile?.emailAddress ?? "Not available"
            //cell.detailTextLabel?.text = "Email Address"
            break
        case .ProfileImage:
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "UserDetails")
            cell.textLabel?.text = userProfile?.UserName ?? "Not available"
            cell.imageView?.image = #imageLiteral(resourceName: "UserProfile")
            if userProfile?.profileURL != nil{
            cell.imageView?.downloadedFrom(link: userProfile!.profileURL!)
            }
            break
        default:
            break
        }
        if cell != nil {
            cell.selectionStyle = .none
        }
        return cell
    }
    
//    func setupProfileCell(indexPath:IndexPath) -> ProfileCell {
//
//        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "ProfileID", for: indexPath) as! ProfileCell
//        cell.ProfileImage.image = #imageLiteral(resourceName: "UserProfile")
//        if userProfile?.profileURL != nil {
//            cell.ProfileImage.downloadedFrom(link: userProfile!.profileURL!)
//        }
//        return cell
//    }
    
//    func getUserProfileImage(OnCompletion: @escaping((String?) -> Void))  {
//
//        if let uid = Auth.auth().currentUser?.uid {
//            ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let userProfileURL = value?["ProfileURL"] as? String
//                OnCompletion(userProfileURL)
//            }) { (error) in
//                print(error.localizedDescription)
//                OnCompletion(nil)
//            }
//        }else{
//            OnCompletion(nil)
//        }
//    }
    
    func setupSyncCell(indexPath:IndexPath) -> SyncCell {
        let cell = SettingTableView.dequeueReusableCell(withIdentifier: "SyncID", for: indexPath) as! SyncCell
        cell.ActivityIndicator.isHidden = true
        cell.Switch.isOn = LeavesHandler.isSyncON()
        cell.Switch.addTarget(self, action: #selector(switchTapped(sender:)), for: UIControlEvents.editingChanged)
        cell.selectionStyle = .none
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


