//
//  LeavesHandler.swift
//  Leaves
//
//  Created by Jay Patel on 29/08/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import UIKit

public class LeavesHandler {
    
    static func isAppRunFirstTime() -> Bool {
        return UserDefaults.standard.bool(forKey: "FirstTimeApp")
    }
    
    static func FirstTimeRun(){
        let storage = UserDefaults.standard
        storage.set(false, forKey: "FirstTimeApp")
        storage.synchronize()
    }
    
    static func isSyncON() -> Bool {
        return UserDefaults.standard.bool(forKey: "Sync")
    }
    
    static func SetSync(isOn:Bool) {
        let storage = UserDefaults.standard
        storage.set(isOn, forKey: "Sync")
        storage.synchronize()
    }
    
    static func isFirstTime() -> Bool {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "FirstTime") == 0
    }
    
    static func DoneFirstTime() {
        let storage = UserDefaults.standard
        storage.set(1, forKey: "FirstTime")
        storage.synchronize()
    }
    
    static func getSickLeaves()  -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "SickLeave")
    }
    
    static func getWorkingLeaves() -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "WorkingLeave")
    }
    
    static func SetSickLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "SickLeave")
        storage.synchronize()
    }
    
    static func SetWorkingLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "WorkingLeave")
        storage.synchronize()
    }
    
    static func getRemainSickLeaves()  -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "RemainSickLeave")
    }
    
    static func getRemainWorkingLeaves() -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "RemainWorkingLeave")
    }
    
    static func SetRemainSickLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "RemainSickLeave")
        storage.synchronize()
    }
    
    static func SetRemainWorkingLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "RemainWorkingLeave")
        storage.synchronize()
    }
    
}
