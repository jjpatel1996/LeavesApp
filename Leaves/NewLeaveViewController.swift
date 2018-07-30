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
    
    var leaveType:LeaveType = .Sick
    
    @IBOutlet weak var newLeaveView: UIView!
    
    var sickLeavesRemain:Int = 0
    var workingLeavesRemain:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTotalLeaves()
        leaveCountTextField.addTarget(self, action: #selector(textDidChanged(sender:)), for: UIControlEvents.editingChanged)
    }
    
    func loadTotalLeaves(){
        sickLeavesRemain = LeavesHandler.getRemainSickLeaves()
        workingLeavesRemain = LeavesHandler.getRemainWorkingLeaves()
    }
    
    @objc func textDidChanged(sender:UITextField){
        if let value = Int(sender.text!) {
            let LeaveRemainForcurrentType = leaveType == .Sick ? sickLeavesRemain : workingLeavesRemain
            if value > LeaveRemainForcurrentType {
                leaveCountTextField.text = String(LeaveRemainForcurrentType)
                IncreaseDecreaseStepper.value = Double(LeaveRemainForcurrentType)
            }
        }
    }
    
    //Animate view
    @IBAction func LeaveCountChangeValue(_ sender: Any) {
        leaveCountTextField.text = String(IncreaseDecreaseStepper.value)
        
    }
    
    @IBAction func LeaveTypeChanged(_ sender: Any) {
        if (sender as! UISegmentedControl).selectedSegmentIndex == 0 {
            leaveType = .Sick
            IncreaseDecreaseStepper.maximumValue = Double(sickLeavesRemain)
        }else{
            leaveType = .Working
            IncreaseDecreaseStepper.maximumValue = Double(workingLeavesRemain)
        }
    }
    
    
    func saveNewLeave(){
        
        var leaveCount = 0
        if let Count = Int(leaveCountTextField.text!){
            leaveCount = Count
        }else{
            self.popupAlertwithoutButton(title: "Oppsy!!", message: "How can you take leave without inserting days 😅")
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
        newLeave.leave_datetime = NSDate()
        newLeave.leave_description = DescriptionTextView.text
        
        do {
            try CoreDataStack.saveContext()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
            showError()
        }
        
    }
    
    @IBAction func SaveButtonTapped(_ sender: Any) {
        //Save in CoreData and Go back.
        saveNewLeave()
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
