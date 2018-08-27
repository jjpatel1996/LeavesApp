//
//  LeavesHistory+CoreDataProperties.swift
//  
//
//  Created by Jay Patel on 27/08/18.
//
//

import Foundation
import CoreData


extension LeavesHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeavesHistory> {
        return NSFetchRequest<LeavesHistory>(entityName: "LeavesHistory")
    }

    @NSManaged public var dead: Int16
    @NSManaged public var leave_count: Int32
    @NSManaged public var leave_datetime: Date?
    @NSManaged public var leave_description: String?
    @NSManaged public var leave_type: String?
    @NSManaged public var leave_createdDTM: Date?
    @NSManaged public var leave_modifiedDTM: Date?

}
