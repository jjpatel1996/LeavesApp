//
//  User+CoreDataProperties.swift
//  Leaves
//
//  Created by Jay Patel on 12/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var contactNo: String?
    @NSManaged public var age: Int64
    @NSManaged public var birthday: Date?
    @NSManaged public var gender: String?

}
