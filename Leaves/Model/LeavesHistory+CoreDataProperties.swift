//
//  LeavesHistory+CoreDataProperties.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//
//

import Foundation
import CoreData


extension LeavesHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeavesHistory> {
        return NSFetchRequest<LeavesHistory>(entityName: "LeavesHistory")
    }

    @NSManaged public var leave_type: String?
    @NSManaged public var leave_count: Int32
    @NSManaged public var leave_description: String?
    @NSManaged public var dead: Int16
    @NSManaged public var leave_datetime: Date?

}
