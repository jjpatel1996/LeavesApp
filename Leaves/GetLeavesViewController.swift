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
    
    var delegate:LeaveSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SickLeaveTextField.text = "0"
        WorkingLeaveTextField.text = "0"
        WorkingLeaveTextField.delegate = self
        SickLeaveTextField.delegate = self
    }

    @IBAction func SubmitLeaves(_ sender: Any) {
        self.view.endEditing(true)
        if let SickLeaveCount = Int(SickLeaveTextField.text!) {
            LeavesHandler.SetSickLeaves(leaves: SickLeaveCount)
            LeavesHandler.SetRemainSickLeaves(leaves: SickLeaveCount)
        }
        
        if let WorkingLeaveCount = Int(WorkingLeaveTextField.text!) {
            LeavesHandler.SetWorkingLeaves(leaves: WorkingLeaveCount)
            LeavesHandler.SetRemainWorkingLeaves(leaves: WorkingLeaveCount)
        }
        
        LeavesHandler.DoneFirstTime()
        delegate?.LeavesSetted()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
