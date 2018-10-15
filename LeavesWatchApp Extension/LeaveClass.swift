//
//  LeaveClass.swift
//  LeavesWatchApp Extension
//
//  Created by Jay Patel on 15/10/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation

class LeaveClass: NSObject {
    
    public var dead: Int16 = 0
    public var leave_count: Int = 0
    public var leave_createdDTM: Date?
    public var leave_datetime: Date?
    public var leave_description: String?
    public var leave_modifiedDTM: Date?
    public var leave_type: String?
  
    override init() {
        super.init()
    }
    
    
}
