//
//  Utility.swift
//  Leaves
//
//  Created by Jay Patel on 29/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Utility:NSObject {
    
    class func downloadAndSaveProfileImage(profilePath:String?){
        
        guard profilePath != nil else { return }
        
        guard let url = URL(string: profilePath!) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            do {
                
                let profilePathToSave = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Profile.png")
                
                let fm = FileManager.default
                
                if fm.fileExists(atPath: profilePathToSave) {
                    try fm.removeItem(atPath: profilePathToSave)
                }
                
                let imageData = image.jpegData(compressionQuality: 1.0)
                
                if fm.createFile(atPath: profilePathToSave as String, contents: imageData, attributes: nil) {
                    print("File Saved")
                }
                
            }catch{
                print("Error in file save")
            }
            
            }.resume()
        
    }

    class func SaveUpdateUserInfo(userDetails:UserDetail) -> Bool {
        
        do {
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            try CoreDataStack.managedObjectContext.execute(request)
            
            var newUser:User!
            if #available(iOS 10.0, *) {
                newUser = User(entity: User.entity(), insertInto: CoreDataStack.managedObjectContext)
            } else {
                
                let entity = NSEntityDescription.entity(forEntityName: "User", in: CoreDataStack.managedObjectContext)!
                newUser = User(entity: entity, insertInto: CoreDataStack.managedObjectContext)
            }
            
            newUser.name = userDetails.UserName
            newUser.email = userDetails.emailAddress
            try CoreDataStack.saveContext()
        } catch {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    class func getDateFromString(dateInString:String) -> Date? {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        //
        return dtFormatter.date(from: dateInString)
    }
}
