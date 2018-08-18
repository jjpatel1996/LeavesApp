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


class FirebaseActivity{
    
    func saveNewUser(){
        
    }
    
    func isUserExist() -> Bool {
        return  Auth.auth().currentUser != nil
    }
    
    func setTotalLeaves(SickLeave:Int,WorkingLeave:Int) -> Bool {
        return false
    }
    
    func SetLeaves(){
        
    }
    
    func GetLeaves(){
        
    }
    
    func SetNewLeave(){
        
    }
    
    func getAllLeaves(){
        
    }
    
}
