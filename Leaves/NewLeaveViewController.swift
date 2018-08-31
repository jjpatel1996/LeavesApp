//
//  NewLeaveViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import CoreData

enum LeaveType:String {
    case Sick = "Sick"
    case Working = "Working"
}

class NewLeaveViewController: UIViewController {
    
    @IBOutlet weak var leaveCountTextField: UITextField!
    
    @IBOutlet weak var IncreaseDecreaseStepper: UIStepper!
    
    @IBOutlet weak var DescriptionTextView: UITextView!
    
    @IBOutlet weak var leaveTypeChanger: UISegmentedControl!
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    
    var leaveType:LeaveType = .Sick
    
    var isNew:Bool = true
    
    var leave:LeavesHistory?
    
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var newLeaveView: UIView!
    
    var delegate:LeaveSetDelegate?
    
    var sickLeavesRemain:Int = 0
    var workingLeavesRemain:Int = 0
    
    var remainTotalLeaveForCurrentSelectedLeave:Int = 0
    
    let firebase = FirebaseActivity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTotalLeaves()
        leaveCountTextField.addTarget(self, action: #selector(textDidChanged(sender:)), for: UIControlEvents.editingChanged)
        DescriptionTextView.layer.cornerRadius = 8
        DatePicker.date = Date()
        DatePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
        DatePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNew {
            leaveCountTextField.text = "0"
            IncreaseDecreaseStepper.maximumValue = Double(sickLeavesRemain)
            IncreaseDecreaseStepper.value = 0
        }else{
            guard leave != nil else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            //Set IDS Max Value
            IncreaseDecreaseStepper.value = Double(leave!.leave_count)
            SaveButton.setTitle("Update", for: .normal)
            leaveTypeChanger.isEnabled = false
            DatePicker.isEnabled = false
            DatePicker.date = leave!.leave_datetime ?? Date()   //Change
            
            if leave!.leave_type == LeaveType.Sick.rawValue {
                leaveType = .Sick
                remainTotalLeaveForCurrentSelectedLeave = sickLeavesRemain + Int(leave!.leave_count)
            }else{
                leaveType = .Working
                remainTotalLeaveForCurrentSelectedLeave = workingLeavesRemain + Int(leave!.leave_count)
            }
            IncreaseDecreaseStepper.maximumValue = Double(remainTotalLeaveForCurrentSelectedLeave)
            leaveCountTextField.text = String(leave!.leave_count)
            DescriptionTextView.text = leave?.leave_description
            
        }
    }
    
    func loadTotalLeaves(){
        sickLeavesRemain = LeavesHandler.getRemainSickLeaves()
        workingLeavesRemain = LeavesHandler.getRemainWorkingLeaves()
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker){
        //Do we need this?
    }
    
    @objc func textDidChanged(sender:UITextField){
        if let value = Int(sender.text!) {
            if isNew {
                let LeaveRemainForcurrentType = leaveType == .Sick ? sickLeavesRemain : workingLeavesRemain
                if value > LeaveRemainForcurrentType {
                    leaveCountTextField.text = String(LeaveRemainForcurrentType)
                    IncreaseDecreaseStepper.value = Double(LeaveRemainForcurrentType)
                }
            }else{
                if value > remainTotalLeaveForCurrentSelectedLeave {
                    leaveCountTextField.text = String(remainTotalLeaveForCurrentSelectedLeave)
                    IncreaseDecreaseStepper.value = Double(remainTotalLeaveForCurrentSelectedLeave)
                }
            }
            
        }
    }
    
    //Animate view
    @IBAction func LeaveCountChangeValue(_ sender: Any) {
        leaveCountTextField.text = String(Int(IncreaseDecreaseStepper.value))
    }
    
    @IBAction func LeaveTypeChanged(_ sender: Any) {
        if (sender as! UISegmentedControl).selectedSegmentIndex == 0 {
            leaveType = .Sick
            IncreaseDecreaseStepper.maximumValue = Double(sickLeavesRemain)
        }else{
            leaveType = .Working
            IncreaseDecreaseStepper.maximumValue = Double(workingLeavesRemain)
        }
        
        if let currentSelectedLeave = Int(leaveCountTextField.text ?? "0"), currentSelectedLeave > Int(IncreaseDecreaseStepper.maximumValue) {
            leaveCountTextField.text = String(Int(IncreaseDecreaseStepper.maximumValue))
        }
        
    }
    
    @IBAction func SaveButtonTapped(_ sender: Any) {
        SaveLeave()
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func SaveLeave(){
        
        if isNew {
            
            var leaveCount = 0
            if let Count = Int(leaveCountTextField.text!){
                leaveCount = Count
            }else{
                self.popupAlertwithoutButton(title: "Oppsy!!", message: "How can you take leave without inserting days 😅")
                return
            }
            
            if leaveCount > Int(IncreaseDecreaseStepper.maximumValue) {
                self.popupAlertwithoutButton(title: "Oppsy!!", message: "How can you take more leaves more then they giving😅")
                return
            }
            
           var newLeave:LeavesHistory!
            if #available(iOS 10.0, *) {
                newLeave = LeavesHistory(entity: LeavesHistory.entity(), insertInto: CoreDataStack.managedObjectContext)
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "LeavesHistory", in: CoreDataStack.managedObjectContext)!
                newLeave = LeavesHistory(entity: entity, insertInto: CoreDataStack.managedObjectContext)
            }
            
            
            newLeave.dead = 0
            newLeave.leave_count = Int32(leaveCount)
            newLeave.leave_type = leaveType.rawValue
            newLeave.leave_datetime = DatePicker.date
            newLeave.leave_createdDTM = Date()
            newLeave.leave_modifiedDTM = Date()
            newLeave.leave_description = DescriptionTextView.text
            
            do {
                try CoreDataStack.saveContext()
                SetLeaveCountInPrefrence(newLeaveCounts: Int(leaveCount))
                saveLeaveInFirebase(leave: newLeave)
                delegate?.LeavesSetted()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
                showError()
            }
            
        }else{
            
            
            let oldValue = Int(leave!.leave_count)
            
            var leaveCount = 0
            if let Count = Int(leaveCountTextField.text!){
                leaveCount = Count
            }else{
                self.popupAlertwithoutButton(title: "Oppsy!!", message: "How can you take leave without inserting days 😅")
                return
            }
        
            if leaveCount > remainTotalLeaveForCurrentSelectedLeave {
                self.popupAlertwithoutButton(title: "Oppsy!!", message: "How can you take more leaves more then they giving😅")
                return
            }
            
            //Update Old Data
            leave!.leave_count = Int32(leaveCount)
            leave!.leave_type = leaveType.rawValue
            leave!.leave_description = DescriptionTextView.text
            leave!.leave_modifiedDTM = Date()
            
            do {
                try CoreDataStack.saveContext()
                SetLeaveCountInPrefrence(newLeaveCounts: leaveCount-oldValue)
                saveLeaveInFirebase(leave: leave!)
                delegate?.LeavesSetted()
                self.dismiss(animated: true, completion: nil)
            } catch {
                print(error.localizedDescription)
                showError()
            }
        } 
    }
    
    func SetLeaveCountInPrefrence(newLeaveCounts:Int){
        
        if leaveType == .Sick {
            LeavesHandler.SetRemainSickLeaves(leaves: sickLeavesRemain-newLeaveCounts)
        }else {
            LeavesHandler.SetRemainWorkingLeaves(leaves: workingLeavesRemain-newLeaveCounts)
        }
        
    }
    
    func saveLeaveInFirebase(leave:LeavesHistory){
        if leave.uniqueFirebaseID == nil {
            firebase.SaveLeave(leave: leave)
        }else{
            firebase.UpdateLeave(leave: leave)
        }
    }
    
    
    
    
    func showError() {
        
        let message = "There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for the inconvenience."
        
        self.popupAlert(title: "Internal Error", message: message, actionTitles: ["Ok"], actions: [ { ok in
            
            let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
            exception.raise()
            }
            ])
    }
    
}
