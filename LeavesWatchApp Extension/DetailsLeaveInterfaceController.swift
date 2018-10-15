//
//  DetailsLeaveInterfaceController.swift
//  LeavesWatchApp Extension
//
//  Created by Jay Patel on 15/10/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import WatchKit

//DetailsID
class DetailsLeaveInterfaceController: WKInterfaceController {

    
    @IBOutlet weak var leaveCountLabel: WKInterfaceLabel!
    @IBOutlet weak var typeOfLeave: WKInterfaceLabel!
    @IBOutlet weak var leaveDescription: WKInterfaceLabel!
    @IBOutlet weak var leaveTakenDate: WKInterfaceLabel!
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let leave = context as? LeaveClass else { return }
        
        leaveCountLabel.setText(String(leave.leave_count))
        leaveTakenDate.setText(getDateToString(date: leave.leave_datetime!))
        typeOfLeave.setText(leave.leave_type)
        leaveDescription.setText(leave.leave_description ?? "Not available")
        
    }
    
    func getDateToString(date:Date) -> String? {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return dtFormatter.string(from: date)
    }
    
    
    
}
