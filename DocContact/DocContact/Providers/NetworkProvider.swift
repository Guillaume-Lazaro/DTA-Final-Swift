//
//  NetworkProvider.swift
//  DocContact
//
//  Created by Benjamin LOUIS on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private let sharedNetServices = NetworkProvider()

class NetworkProvider{
    let API_URL: String = "http://familink.cleverapps.io"
    let publicModifier: String = "/public"
    let protectedModifier: String = "/secured/users"
    var token : String?
    
    class var sharedInstance: NetworkProvider {
        return sharedNetServices
    }
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // TODO : Garder le token en base locale, récupérer le profil
    func loginOnServer(phone: String, password: String, success: @escaping () -> (), failure: @escaping () ->()){
        var json = [String:String]()
        json["phone"] = phone
        json["password"] = password
        let urlString = self.API_URL+self.publicModifier+"/login";
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            // TODO : si ok -> stocker token(data) et passer à la liste (charger contacts)
            do {
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    failure()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    guard let token = responseJSON["token"] else{
                        print("not a token")
                        failure()
                        return
                    }
                    self.token = token as? String
                    print(token)
                    success()
                }
            }
        }
        task.resume()
    }
    
    // TODO : Ajouter user en base locale
    func signUpOnServer(phone: String, password: String, firstname: String, lastname: String, mail: String, profile: String, success: @escaping () -> (), failure: @escaping () -> ()) {
        var json = [String:String]()
        json["phone"] = phone
        json["password"] = password
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        let urlString = API_URL+publicModifier+"/sign-in?contactsLength=0";
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    failure()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: String]{
                    if let message = responseJSON["message"]{
                        print(message)                        
                        failure()
                        return
                    }
                    print("inscription valide")
                    success()
                }
            }
        }
        task.resume()
    }
    
    func forgotPassword(phone: String, success: @escaping () -> (), failure: @escaping () -> ()){
        var json = [String:String]()
        json["phone"] = phone
        let urlString = self.API_URL+self.publicModifier+"/forgot-password";
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    failure()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String:String]{
                    if let message = responseJSON["message"]{
                        print(message)
                        failure()
                        return
                    }
                    print("user valide donc envoi mdp")
                    success()
                }
            }
        }
        task.resume()
    }
    
    // TODO : Renvoyer la liste reçue
    func getContacts(){
        guard let token: String = self.token! else{
            print("Le token n'est pas défini")
        }
        let urlString = API_URL + protectedModifier + "/contacts"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            do {
                print(data ?? "Pas de data")
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let resp = responseJSON as? [[String:Any]] else{
                    return
                }
                print(resp)
                let managerDB = ManageDbProvider.init()
                managerDB.fillCoreDataWithContacts(json: resp)
                //return resp
                
            }
        }
        task.resume()
    }
    
    // TODO : Que faire en cas de suppression
    func deleteContact(id: String, token: String){
        let urlString = API_URL + protectedModifier + "/contacts/id"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            do {
                print(data ?? "Pas de data")
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                print(responseJSON)
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
                
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    //TODO : tester l'update
    func updateContact(phone: String, firstname: String, lastname: String, mail: String, profile: String, gravatar: String, id: String, token: String ){
        var json = [String:Any]()
        json["phone"] = phone
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        json["gravatar"] = gravatar
        json["isFamilinkUser"] = false
        json["isEmergencyUser"] = false
        let urlString = API_URL + protectedModifier + "/"+id;
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]{
                    if let message = responseJSON["message"]{
                        print(message)
                        
                        return
                    }
                    print("Contact modifié")
                }
            }
        }
        task.resume()
    }
    
    // TODO : tester la création
    func createContact(phone: String, firstname: String, lastname: String, mail: String, profile: String, gravatar: String, id: String, token: String ){
        var json = [String:Any]()
        json["phone"] = phone
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        json["gravatar"] = gravatar
        json["isFamilinkUser"] = false
        json["isEmergencyUser"] = false
        let urlString = API_URL + protectedModifier + "/"+id;
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]{
                    if let message = responseJSON["message"]{
                        print(message)
                        
                        return
                    }
                    print("Contact crééé")
                }
            }
        }
        task.resume()
    }
    
    // TODO : l'utiliser pour les profiles d'inscription
    func getProfiles(success: @escaping ([String])->()) -> (){
        var profiles: [String]=[""]
        let urlString = API_URL+publicModifier+"/profiles"
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String]{
                    // print(responseJSON)
                    profiles=responseJSON
                    success(profiles)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
}
