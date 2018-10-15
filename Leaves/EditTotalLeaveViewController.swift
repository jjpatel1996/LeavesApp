//
//  EditTotalLeaveViewController.swift
//  Leaves
//
//  Created by Jay Patel on 26/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

enum EditLeaveType:String {
    case TotalWorkingLeaves = "Total Working Leaves"
    case TotalSickLeaves = "Total Sick Leaves"
    case RemainSickLeaves = "Remain Sick Leaves"
    case RemainWorkingLeaves = "Remain Working Leaves"
}

//EditTotalLeaveID
class EditTotalLeaveViewController: UITableViewController, UITextFieldDelegate {

    var totalSickLeaves:Int = 0
    var totalWorkingLeaves:Int = 0
   
    var sectionList = [EditLeaveType.TotalWorkingLeaves,EditLeaveType.TotalSickLeaves]
    
    var editButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Total Leave"
        tableView.tableFooterView = UIView()
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(editButtonTapped(sender:)))
        self.navigationItem.rightBarButtonItem = editButton
        fetchLeaves()
    }
    
    func fetchLeaves(){
        totalSickLeaves = LeavesHandler.getSickLeaves()
        totalWorkingLeaves = LeavesHandler.getWorkingLeaves()
    }
    
    @objc func editButtonTapped(sender:UIBarButtonItem){
        
        if editButton.title == "Edit" {
            editButton.title = "Save"
        }else{
            guard totalSickLeaves != 0 || totalWorkingLeaves != 0 else {
                self.popupAlertWithoutHandler(title: "Message", message: "Leaves count can't be empty", actionTitles: ["Ok"])
                return
            }
            
            self.view.endEditing(true)
            editButton.title = "Edit"
            
            LeavesHandler.SetSickLeaves(leaves: totalSickLeaves)
            LeavesHandler.SetWorkingLeaves(leaves: totalWorkingLeaves)
            //FirebaseActivity().UpdateTotalLeavesToFirebase()
        }
        self.tableView.reloadData()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let cell = textField.superview?.superview as? EditTotalLeaveCell else { return }
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard cell.leaveTextField.text != "" else {
            self.popupAlertWithoutHandler(title: nil, message: "Leave count can't be empty", actionTitles: ["Dismiss"])
            return
        }
        
        switch sectionList[indexPath.section] {
        case .TotalWorkingLeaves:
            totalWorkingLeaves = Int(cell.leaveTextField.text!)!
            break
        case .TotalSickLeaves:
            totalSickLeaves = Int(cell.leaveTextField.text!)!
            break
        default:
            break
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section].rawValue
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextFieldID", for: indexPath) as! EditTotalLeaveCell
       
        cell.leaveTextField.isEnabled = editButton.title == "Save"
        cell.leaveTextField.delegate = self
        
        switch sectionList[indexPath.section] {
        case .TotalWorkingLeaves:
            cell.leaveTextField.text = String(totalWorkingLeaves)
            break
        case .TotalSickLeaves:
            cell.leaveTextField.text = String(totalSickLeaves)
            break
        default:
            break
        }
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
