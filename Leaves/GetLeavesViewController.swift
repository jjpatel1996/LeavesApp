//
//  GetLeavesViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

//GetLeavesID
class GetLeavesViewController: UIViewController {

    @IBOutlet weak var SickLeaveTextField: UITextField!
    
    @IBOutlet weak var WorkingLeaveTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func SubmitLeaves(_ sender: Any) {
        
        if let SickLeaveCount = Int(SickLeaveTextField.text!) {
            LeavesHandler.SetSickLeaves(leaves: SickLeaveCount)
        }
        
        if let WorkingLeaveCount = Int(WorkingLeaveTextField.text!) {
            LeavesHandler.SetWorkingLeaves(leaves: WorkingLeaveCount)
        }
        
        LeavesHandler.SetRemainSickLeaves(leaves: 0)
        LeavesHandler.SetWorkingLeaves(leaves: 0)
        self.dismiss(animated: true, completion: nil)
    }
    

}
