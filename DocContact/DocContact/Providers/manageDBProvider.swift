//
//  manageDBProvider.swift
//  DocContact
//
//  Created by Thomas on 29/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import CoreData

class ManageDbProvider{
    
    
    
    func fillCoreDataWithContacts(json: [[String : Any]]){                    // Passed in data from remote DB
        let sort = NSSortDescriptor(key: "lastName", ascending: true)
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [sort]
        
        //let appDelegate = self.appDelegate()
        let netProvider = NetworkProvider.sharedInstance
        let appDelegate = netProvider.persistentContainer
        let context = appDelegate.viewContext
      //  let context = appDelegate.persistentContainer.viewContext
        let contacts : [Contact] = try! context.fetch(fetchRequest)           // Data from local DB
        // Create an array of id
//        let personIds = contacts.map({ (p) -> String? in
//            return p.id
//        })
        // Create another array of id
//        let serversId = json.map { (dict) -> String in
//            return dict["id"] as? String ?? "0"
//        }
        
        //Delete data that is not in the server
//        for contact in contacts {
//            if !serversId.contains(String(describing: contact.id)){
//                context.delete(contact)
//            }
//        }
        
        // create
        for jsonPerson in json{
           //print("une personne ===>", jsonPerson)
            let contact = Contact(context: context)
            contact.lastName = jsonPerson["lastName"] as? String
            contact.firstName = jsonPerson["firstName"] as? String
            contact.email = jsonPerson["email"] as? String
            contact.phone = jsonPerson["phone"] as? String
            contact.profile = jsonPerson["profile"] as? String
            contact.gravatar = jsonPerson["gravatar"] as? String
            
            contact.id = jsonPerson["_id"] as? String

            guard let emergencyUser = jsonPerson["isEmergencyUser"] as? Int else{
                print("ERROR")
                return
            }
            if(emergencyUser == 0){
                contact.isEmergencyUser = false
            }else{
                contact.isEmergencyUser = true
            }
            guard let familinkUser = jsonPerson["isFamilinkUser"] as? Int else{
                print("ERROR")
                return
            }
            if(familinkUser == 0){
                contact.isFamilinkUser = false
            }else{
                contact.isFamilinkUser = true
            }
            
        
            do{
                if context.hasChanges{
                    try context.save()
                    print("contact bien enregistré en base ")
                }
            }catch{
                print(error)
            }

        }
 
    }
    
    func appDelegate() -> AppDelegate{
        return (UIApplication.shared.delegate as? AppDelegate)!
    }
}

 
