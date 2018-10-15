//
//  InterfaceController.swift
//  LeavesWatchApp Extension
//
//  Created by Jay Patel on 15/10/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import WatchKit
import Foundation

class LeavesInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var listOfLeaves = [LeaveClass]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        dummyData()
        tableView.setNumberOfRows(listOfLeaves.count, withRowType: "LeaveRow")
        for index in 0 ..< tableView.numberOfRows {
            guard let controller = tableView.rowController(at: index) as? LeaveRowController else { continue }
            controller.leave = listOfLeaves[index]
        }
    }
    
    func dummyData(){
        
        let list = [2,4,5,1,2,3,6,7,3,5,7]
        let list2 = ["Was sick","For vacation","Birthday","For Marriage","Build and run. Follow the same steps as before to check-in for a flight, and you’ll see that when you’re returned to the schedule interface controller, the colors of the plane image and separator on the corresponding table row crossfade to a new color"]
        let list3 = ["Sick","Paid"]
        
        for _ in 0..<10  {
            let leave = LeaveClass()
            leave.dead = 0
            leave.leave_createdDTM = Date()
            leave.leave_modifiedDTM = Date()
            leave.leave_datetime = Date()
            leave.leave_type = list3[Int(arc4random_uniform(2))]
            leave.leave_description = list2[Int(arc4random_uniform(5))]
            leave.leave_count = list[Int(arc4random_uniform(10))]
            listOfLeaves.append(leave)
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print("Tapped")
        presentController(withName: "DetailsID", context: listOfLeaves[rowIndex])
    }
    
    
}
