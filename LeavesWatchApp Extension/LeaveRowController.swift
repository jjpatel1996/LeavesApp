//
//  LeaveRowController.swift
//  LeavesWatchApp Extension
//
//  Created by Jay Patel on 15/10/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import WatchKit


class LeaveRowController: NSObject {

    @IBOutlet weak var LeaveTypeLabel: WKInterfaceLabel!
    @IBOutlet weak var LeaveCountLabel: WKInterfaceLabel!
    @IBOutlet weak var LeaveDescriptionLabel: WKInterfaceLabel!
    
    var leave:LeaveClass? {
        didSet{
            LeaveTypeLabel.setText(leave!.leave_type)
            LeaveCountLabel.setText("Count \(leave!.leave_count)")
            LeaveDescriptionLabel.setText(leave!.leave_description)
        }
    }
    
    override init() {
        super.init()
    }
    
}
