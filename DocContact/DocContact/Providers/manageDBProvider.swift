//
//  manageDBProvider.swift
//  DocContact
//
//  Created by Thomas on 29/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import CoreData

private let sharedManageDbProvider = ManageDbProvider()

class ManageDbProvider{
    let netProvider = NetworkProvider.sharedInstance
    class var sharedInstance: ManageDbProvider {
        return sharedManageDbProvider
    }
    
    func createCoreDataUser(userJson: [String: String]){
        let appDelegate = netProvider.persistentContainer
        let context = appDelegate.viewContext
        let user = User(context: context)
        user.lastName = userJson["lastName"]
        user.firstName = userJson["firstName"]
        user.phone = userJson["phone"]
        user.email = userJson["email"]
        user.profile = userJson["profile"]
        user.token = netProvider.token
        do{
            if context.hasChanges{
                try context.save()
            }
        }catch{
            print(error)
        }
        print("L'utilisateur a été ajouté à la base")
    }
    func getUser()->User?{
        let fetchRequestUser = NSFetchRequest<User>(entityName : "User")
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchedUser = try managedContext.fetch(fetchRequestUser)
            print(fetchedUser.first?.lastName)
            return fetchedUser.first
        } catch {
            fatalError("Failed to fetch Users: \(error)")
        }
    }
    
    func deleteUsersFromCoreData(){
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        let netProvider = NetworkProvider.sharedInstance
        let appDelegate = netProvider.persistentContainer
        let context = appDelegate.viewContext
        let contacts : [User] = try! context.fetch(fetchRequest)
        
        contacts.forEach { (user) in
            context.delete(user)
            do{
                if context.hasChanges{
                    try context.save()
                }
            }catch{
                print(error)
            }
        }
        print("La base ne contient plus d'utilisateurs")
    }
    
    
    func fillCoreDataWithContacts(json: [[String : Any]]){                    // Passed in data from remote DB
        let sort = NSSortDescriptor(key: "lastName", ascending: true)
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [sort]
        let appDelegate = netProvider.persistentContainer
        let context = appDelegate.viewContext
        // create
        for jsonPerson in json{
            let contact = Contact(context: context)
            // contact.user = context
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
                }
            }catch{
                print(error)
            }
            
        }
        print("Les contacts ont bien été ajoutés à la base de données locale")
    }
    
    func wipeContacts(){
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        let netProvider = NetworkProvider.sharedInstance
        let appDelegate = netProvider.persistentContainer
        let context = appDelegate.viewContext
        let contacts : [Contact] = try! context.fetch(fetchRequest)
        
        contacts.forEach { (contact) in
            context.delete(contact)
            do{
                if context.hasChanges{
                    try context.save()
                }
            }catch{
                print(error)
            }
        }
        print("les contacts ont été supprimés de la base")
    }
}
