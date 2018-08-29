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


class FirebaseActivity: NSObject {
    
    var ref = Database.database().reference()
    
    var UserID:String?
    
    override init() {
        UserID = Auth.auth().currentUser?.uid
    }
    
    func saveNewUser() {
    
        
    }
    
    func insertUserFirebase(userID:String,Email:String,FName:String?,LName:String?,ContactNo:String?,imageURL:URL?){
        
        var UserDictionary: [String:Any] = ["Email":Email,"isVerified":false]
        
        if imageURL != nil {
            UserDictionary["ProfileURL"] = imageURL!.absoluteString
        }
        
        if FName != nil {
            UserDictionary["FirstName"] = FName
        }
        if LName != nil {
            UserDictionary["LastName"] = LName
        }
        if ContactNo != nil {
            UserDictionary["ContactNo"] = ContactNo
        }
    
        ref.child("users").child(userID).setValue(UserDictionary){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("insertUser could not be saved: \(error).")
            } else {
                print("insertUser saved successfully!")
            }
        }
    }
    
    func isUserExist() -> Bool {
        return  Auth.auth().currentUser != nil
    }
    
    func setTotalLeaves(sickLeave:Int,workingLeave:Int) -> Bool {
        
        guard isUserExist() else { return false }
        
        ref.child("TotalLeaves").child(UserID!).setValue(["SickLeave":sickLeave,"WorkingLeave":workingLeave]){
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
        guard isUserExist() else { return false }
        
        ref.child("TotalLeaves").child(UserID!).updateChildValues(["SickLeave":sickLeave,"WorkingLeave":workingLeave]){
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
        //Save in FB
        guard isUserExist() else { return }
            
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        
        let leave:[String : Any] = ["leaveType":leave.leave_type ?? "",
                     "Description":leave.leave_description ?? "",
                     "Total":leave.leave_count,
                     "DateTime":dtFormatter.string(from: leave.leave_datetime!),
                     "createdDTM":dtFormatter.string(from: leave.leave_createdDTM!),
                     "modifiedDTM":dtFormatter.string(from: leave.leave_modifiedDTM!),
                     "dead":leave.dead,
                     ]
        ref.child("Leaves").child(UserID!).childByAutoId().setValue(leave){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("SaveLeave could not be saved: \(error).")
            } else {
                print("SaveLeave saved successfully!")
            }
        }
        
    }
    
    // Return only selected Type of
    func getLeaves(leaveType:LeaveType){
        
    }
    
    //Working or Sick.
    func UpdateLeave(leaveUniqueID:String,leave:LeavesHistory){

        guard isUserExist() else { return }
        
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
            
            let leave:[String : Any] = ["leaveType":leave.leave_type ?? "",
                                        "Description":leave.leave_description ?? "",
                                        "Total":leave.leave_count,
                                        "DateTime":dtFormatter.string(from: leave.leave_datetime!),
                                        "modifiedDTM":dtFormatter.string(from: leave.leave_modifiedDTM!),
                                        "dead":leave.dead,
                                        ]
            
            ref.child("Leaves").child(UserID!).child(leaveUniqueID).updateChildValues(leave) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("UpdateLeave could not be saved: \(error).")
                } else {
                    print("UpdateLeave saved successfully!")
                }
            }
        
    }
    
    // Return all leaves for viewController
    func getAllLeaves(){
        
        guard isUserExist() else { return }
        
        ref.child("Leaves").child(UserID!).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
       ref.child("TotalLeaves").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
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

        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        getCurrentTotalLeaves(userID: userID) { (Sick, Working) in
            
            if Sick != nil && Working != nil {
        
                LeavesHandler.SetSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetRemainSickLeaves(leaves: Int(Sick!)!)
                LeavesHandler.SetWorkingLeaves(leaves: Int(Working!)!)
                LeavesHandler.SetRemainWorkingLeaves(leaves: Int(Working!)!)
                LeavesHandler.DoneFirstTime()
                
            }else{
             
                let totalSickLeaves = LeavesHandler.getSickLeaves() + LeavesHandler.getRemainSickLeaves()
                let totalWorkingLeaves = LeavesHandler.getWorkingLeaves() + LeavesHandler.getRemainWorkingLeaves()
                _ = self.setTotalLeaves(sickLeave: totalSickLeaves, workingLeave: totalWorkingLeaves)
                
            }
        }
    
    }
    
}
