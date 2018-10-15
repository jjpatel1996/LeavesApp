//
//  GetLeavesViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

protocol LeaveSetDelegate {
    func LeavesSetted()
}

//GetLeavesID
class GetLeavesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var paidLeaveTextBox: UILabel!
    @IBOutlet weak var sickLeaveTextBox: UILabel!
    
    @IBOutlet weak var leaveSlider: UISlider!
    @IBOutlet weak var sickLeaveSlider: UISlider!
    
    //let fActivity = FirebaseActivity()
    var delegate:LeaveSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        let changedValue = Int((sender as! UISlider).value)
        if (sender as! UISlider).isEqual(leaveSlider){
            paidLeaveTextBox.text = "(Paid) Leaves (\(changedValue))"
        }else{
            sickLeaveTextBox.text = "Sick Leaves (Optional) (\(changedValue))"
        }
    }
    
   /* @IBAction func SubmitLeaves(_ sender: Any) {
        self.view.endEditing(true)
       
        let SickLeaveCount = Int(sickLeaveSlider.value)
        LeavesHandler.SetSickLeaves(leaves: SickLeaveCount)
        LeavesHandler.SetRemainSickLeaves(leaves: SickLeaveCount)

        let WorkingLeaveCount = Int(leaveSlider.value)
        LeavesHandler.SetWorkingLeaves(leaves: WorkingLeaveCount)
        LeavesHandler.SetRemainWorkingLeaves(leaves: WorkingLeaveCount)

        //saveInFirebase(SickLeave: SickLeaveCount, WorkingLeave: WorkingLeaveCount)
        saveAndDismissView()
    }*/
    
    func saveAndDismissView(){
       // FirebaseActivity().UpdateTotalLeavesToFirebase()
        delegate?.LeavesSetted()
        self.dismiss(animated: true, completion: nil)
    }

 
    @IBAction func SaveTapped(_ sender: Any) {
        
        let SickLeaveCount = Int(sickLeaveSlider.value)
        LeavesHandler.SetSickLeaves(leaves: SickLeaveCount)
        LeavesHandler.SetRemainSickLeaves(leaves: SickLeaveCount)
        
        let WorkingLeaveCount = Int(leaveSlider.value)
        LeavesHandler.SetWorkingLeaves(leaves: WorkingLeaveCount)
        LeavesHandler.SetRemainWorkingLeaves(leaves: WorkingLeaveCount)
        saveAndDismissView()
    }
    
    @IBAction func CancelTapped(_ sender: Any) {
        saveAndDismissView()
    }
    
}
