//
//  LeavesHistory+CoreDataClass.swift
//  
//
//  Created by Jay Patel on 29/08/18.
//
//

import Foundation
import CoreData

@objc(LeavesHistory)
public class LeavesHistory: NSManagedObject {

    func setUniqueID(key:String){
        self.uniqueFirebaseID = key
        try? CoreDataStack.saveContext()
    }
    
}
