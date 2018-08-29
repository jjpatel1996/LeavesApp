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

    @IBOutlet weak var SickLeaveTextField: UITextField!
    @IBOutlet weak var WorkingLeaveTextField: UITextField!
    let fActivity = FirebaseActivity()
    var delegate:LeaveSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SickLeaveTextField.text = nil
        WorkingLeaveTextField.text = nil
        WorkingLeaveTextField.delegate = self
        SickLeaveTextField.delegate = self
    }

    @IBAction func SubmitLeaves(_ sender: Any) {
        self.view.endEditing(true)
        guard let SickLeaveCount = Int(SickLeaveTextField.text!)  else { return }
        LeavesHandler.SetSickLeaves(leaves: SickLeaveCount)
        LeavesHandler.SetRemainSickLeaves(leaves: SickLeaveCount)

        guard let WorkingLeaveCount = Int(WorkingLeaveTextField.text!)  else { return }
        LeavesHandler.SetWorkingLeaves(leaves: WorkingLeaveCount)
        LeavesHandler.SetRemainWorkingLeaves(leaves: WorkingLeaveCount)

        //saveInFirebase(SickLeave: SickLeaveCount, WorkingLeave: WorkingLeaveCount)
        saveAndDismissView()
    }
    
    func saveAndDismissView(){
        FirebaseActivity().UpdateTotalLeavesToFirebase()
        LeavesHandler.DoneFirstTime()
        delegate?.LeavesSetted()
        self.dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
