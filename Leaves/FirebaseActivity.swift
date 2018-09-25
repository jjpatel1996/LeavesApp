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
    
    func setTotalLeaves(sickLeave:Int,workingLeave:Int) -> Bool {
        
        guard isReachable else { return false }
        
        guard isUserExist() else { return false }
        
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
    
    func SaveLeave(leave:LeavesHistory){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
            
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
    
    func DeleteLeave(leave:LeavesHistory){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        
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
    
    // Return all leaves for viewController
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
        
        getCurrentTotalLeaves(userID: userID) { (Sick, Working) in
            
            if Sick != nil && Working != nil {
        
                LeavesHandler.SetSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetRemainSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetWorkingLeaves(leaves: Int(Working!)!)
                LeavesHandler.SetRemainWorkingLeaves(leaves: Int(Working!)!)
                
            }else{
             
                let totalSickLeaves = LeavesHandler.getSickLeaves() + LeavesHandler.getRemainSickLeaves()
                let totalWorkingLeaves = LeavesHandler.getWorkingLeaves() + LeavesHandler.getRemainWorkingLeaves()
                _ = self.setTotalLeaves(sickLeave: totalSickLeaves, workingLeave: totalWorkingLeaves)
                
            }
        }
    
    }
    
    func syncAllLeavesToDB(){
        
        guard isReachable else { return }
        guard isUserExist() else { return }
        
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()

        do {
            
            let fetchedResults = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            guard fetchedResults.count > 0 else { return }

            for leave in fetchedResults {
                if leave.uniqueFirebaseID == nil {
                    SaveLeave(leave: leave)
                }
            }
        
        } catch let error as NSError {
            print(error.description)
            
        }
        
    }
    
}
