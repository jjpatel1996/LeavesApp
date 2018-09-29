//
//  FirebaseActivity.swift
//  Leaves
//
//  Created by Jay Patel on 18/08/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import UIKit
import CoreData


class FirebaseActivity: NSObject {
    
    var ref = Database.database().reference()

    var UserID:String?
    
    override init() {
        UserID = Auth.auth().currentUser?.uid
    }
    
    //MARK:-----------User--------------
    
    func insertUserFirebase(userID:String,user:UserDetail){
        
        guard isReachable else { return }
        
        var UserData: [String:Any] = [:]
        UserData["FirstName"] = user.UserName
        UserData["Email"] = user.emailAddress
        
        ref.child(LeaveTableNames.User.rawValue).child(userID).setValue(UserData){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("insertUser could not be saved: \(error).")
            } else {
                print("insertUser saved successfully!")
            }
        }
    }
    
    func UpdateUserInfo(userID:String,user:UserDetail) -> Bool {
        
        guard isReachable else { return false }
        
        var UserDictionary: [String:Any] = [:]
        UserDictionary["FirstName"] = user.UserName
        UserDictionary["Email"] = user.emailAddress
        
        ref.child(LeaveTableNames.User.rawValue).child(userID).updateChildValues(UserDictionary){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("insertUser could not be saved: \(error).")
            } else {
                print("insertUser saved successfully!")
            }
        }
        return true //Use Closure for update value
    }
    
    func isUserExist() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    //MARK:-----------Total Leave--------------
    
    func setTotalLeaves(sickLeave:Int,workingLeave:Int) -> Bool {
        
        guard isReachable else { return false }
        guard isUserExist() else { return false }
        guard LeavesHandler.isSyncON() else { return false }
        
        ref.child(LeaveTableNames.TotalLeaves.rawValue).child(UserID!).setValue(["SickLeave":sickLeave,"WorkingLeave":workingLeave]){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("AddTotal could not be saved: \(error).")
            } else {
                print("AddTotal saved successfully!")
            }
        }
        return true
    }
    
    func updateTotalLeaves(sickLeave:Int,workingLeave:Int) -> Bool {
        
        guard isReachable else { return false }
        guard isUserExist() else { return false }
        guard LeavesHandler.isSyncON() else { return false }
        
        ref.child(LeaveTableNames.TotalLeaves.rawValue).child(UserID!).updateChildValues(["SickLeave":sickLeave,"WorkingLeave":workingLeave]){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("updateTotal could not be saved: \(error).")
            } else {
                print("updateTotal saved successfully!")
            }
        }
        return true
    }
    
    func getCurrentTotalLeaves(userID:String, completion: @escaping ((_ SickLeave:String?, _ WorkingLeave:String?) -> Void)){
        
        guard isReachable else {
            completion(nil, nil)
            return
        }
        
        ref.child(LeaveTableNames.TotalLeaves.rawValue).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot.value ??  "Not found")
            
            if let data = snapshot.value as? NSDictionary {
                completion(data["SickLeave"] as? String, data["WorkingLeave"] as? String)
            }else{
                completion(nil, nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, nil)
        }
        
    }
    
    func UpdateTotalLeavesToFirebase(){
        
        guard isReachable else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard LeavesHandler.isSyncON() else { return }
        
        getCurrentTotalLeaves(userID: userID) { (Sick, Working) in
            
            if Sick != nil && Working != nil {
                
                LeavesHandler.SetSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetRemainSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetWorkingLeaves(leaves: Int(Working!)!)
                LeavesHandler.SetRemainWorkingLeaves(leaves: Int(Working!)!)
                
            }else{
                
                let totalSickLeaves = LeavesHandler.getSickLeaves()
                let totalWorkingLeaves = LeavesHandler.getWorkingLeaves()
                _ = self.setTotalLeaves(sickLeave: totalSickLeaves, workingLeave: totalWorkingLeaves)
                
            }
        }
        
    }
    
    //MARK:-----------Leave--------------
    
    func SaveLeave(leave:LeavesHistory){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        guard LeavesHandler.isSyncON() else { return }
        
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        
        let leaveData:[String : Any] = ["leaveType":leave.leave_type ?? "",
                     "Description":leave.leave_description ?? "",
                     "Total":leave.leave_count,
                     "DateTime":dtFormatter.string(from: leave.leave_datetime!),
                     "createdDTM":dtFormatter.string(from: leave.leave_createdDTM!),
                     "modifiedDTM":dtFormatter.string(from: leave.leave_modifiedDTM!),
                     "dead":leave.dead,
                     ]
        ref.child(LeaveTableNames.Leaves.rawValue).child(UserID!).childByAutoId().setValue(leaveData){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("SaveLeave could not be saved: \(error).")
            } else {
                print("SaveLeave saved successfully!")
                leave.setUniqueID(key: ref.key)
                print(ref.key)
                
            }
        }
        
    }
    
    // Return only selected Type of
    func getLeaves(leaveType:LeaveType){
        
    }
    
    //Working or Sick.
    func UpdateLeave(leave:LeavesHistory){

        guard isReachable else { return }
        guard isUserExist() else { return }
        guard LeavesHandler.isSyncON() else { return }
        
        guard leave.uniqueFirebaseID != nil else { return }
        
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
            
            let leaveData:[String : Any] = ["leaveType":leave.leave_type ?? "",
                                        "Description":leave.leave_description ?? "",
                                        "Total":leave.leave_count,
                                        "DateTime":dtFormatter.string(from: leave.leave_datetime!),
                                        "modifiedDTM":dtFormatter.string(from: leave.leave_modifiedDTM!),
                                        "dead":leave.dead,
                                        ]
            
            ref.child(LeaveTableNames.Leaves.rawValue).child(UserID!).child(leave.uniqueFirebaseID!).updateChildValues(leaveData) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("UpdateLeave could not be saved: \(error).")
                } else {
                    print("UpdateLeave saved successfully!")
                }
            }
        
    }
    
    //Don't Delete Just Set Dead = 1 User UpdateLeave Method
    func DeleteLeave(leave:LeavesHistory){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        guard LeavesHandler.isSyncON() else { return }
        guard leave.uniqueFirebaseID != nil else { return }
        
        ref.child(LeaveTableNames.Leaves.rawValue).child(UserID!).child(leave.uniqueFirebaseID!).removeValue(){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("DeleteLeave could not be deleted: \(error).")
            } else {
                print("Delete Leave Successfully!")
            }
        }
        
    }
    
   
    func getAllLeaves(){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        
        ref.child(LeaveTableNames.Leaves.rawValue).child(UserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot.value ??  "Not found")
            if let IDPair = snapshot.value as? [String:NSDictionary] {
                print(IDPair.description)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    func syncAllLeavesToDB(){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        guard LeavesHandler.isSyncON() else { return }
     
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()
      
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            do {
                
                let fetchedResults = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
                guard fetchedResults.count > 0 else { return }
                
                for leave in fetchedResults {
                    if leave.uniqueFirebaseID == nil {
                        self.SaveLeave(leave: leave)
                    }
                }
                
            } catch let error as NSError {
                print(error.description)
            }
        }
        
    }
    
    
    func syncTotalLeaveFromFirebaseToApp(completion:((_ isUpdated:Bool) -> ())?){
        
        guard isReachable else { completion?(false); return }
        guard let userID = Auth.auth().currentUser?.uid else { completion?(false); return }
        
        //Set Total Working and Sick leave if Local is empty.
        if LeavesHandler.getWorkingLeaves() == 0 && LeavesHandler.getSickLeaves() == 0 {
            getCurrentTotalLeaves(userID: userID) { (SickLeave, WorkingLeave) in
                if WorkingLeave != nil && SickLeave != nil {
                    guard let workingLeaveInt = Int(WorkingLeave!), let sickLeaveInt = Int(SickLeave!) else {
                        completion?(false)
                        return
                    }
                    //Update it
                    LeavesHandler.SetSickLeaves(leaves: sickLeaveInt)
                    LeavesHandler.SetWorkingLeaves(leaves: workingLeaveInt)
                    completion?(true)
                }
            }
        }
    }
    
    func syncLeavesFromFirebaseToApp(){
        
        guard isReachable else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        //get From Local DB
        var currentLeaveList = [LeavesHistory]()
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "dead = %@", argumentArray: [0])
        
        do {
            let fetchedResults = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            if fetchedResults.count > 0 {
               currentLeaveList = fetchedResults
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    
//        //get From Server DB
        ref.child(LeaveTableNames.Leaves.rawValue).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in

            print(snapshot.childrenCount)
           
            if let IDPair = snapshot.value as? [String:NSDictionary] {
                
                for leaveObject in IDPair {
                
                    guard (leaveObject.value["dead"] as! Int) == 0 else { continue }
                    
                    var newLeave:LeavesHistory!
                    if #available(iOS 10.0, *) {
                        newLeave = LeavesHistory(entity: LeavesHistory.entity(), insertInto: CoreDataStack.managedObjectContext)
                    } else {
                        let entity = NSEntityDescription.entity(forEntityName: "LeavesHistory", in: CoreDataStack.managedObjectContext)!
                        newLeave = LeavesHistory(entity: entity, insertInto: CoreDataStack.managedObjectContext)
                    }
                    
                    guard let createdDTMS = leaveObject.value["createdDTM"] as? String else { continue }
                    guard let createdDTM = Utility.getDateFromString(dateInString: createdDTMS) else { continue }
                    
                    guard !currentLeaveList.contains(where: { $0.leave_createdDTM == createdDTM }) else { continue }
                  
                
                    guard let DateTimeS = leaveObject.value["DateTime"] as? String else { continue }
                    guard let DateTime = Utility.getDateFromString(dateInString: DateTimeS) else { continue }
                    
                    guard let modifiedDTMS = leaveObject.value["modifiedDTM"] as? String else { continue }  //String Fromate
                    guard let modifiedDTM = Utility.getDateFromString(dateInString: modifiedDTMS) else { continue } //Date Formate
                    
                    guard let leaveCount = leaveObject.value["Total"] as? Int32 else { continue }
                    guard let dead = leaveObject.value["dead"] as? Int16 else { continue }
                    guard let leaveType = leaveObject.value["leaveType"] as? String else { continue }
                    guard let Description = leaveObject.value["Description"] as? String else { continue }
                    
                    
                    newLeave.dead = dead
                    newLeave.leave_count = leaveCount
                    newLeave.leave_type = leaveType
                    newLeave.leave_datetime = DateTime
                    newLeave.leave_createdDTM = createdDTM
                    newLeave.leave_modifiedDTM = modifiedDTM
                    newLeave.leave_description = Description
                    newLeave.uniqueFirebaseID = leaveObject.key
                    
                }
                
                do {
                    try CoreDataStack.saveContext()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
}
