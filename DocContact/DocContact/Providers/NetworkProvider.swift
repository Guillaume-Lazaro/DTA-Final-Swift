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
    func loginOnServer(phone: String, password: String, success: @escaping ([String: String]) -> (), failure: @escaping () ->()){
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
                    var user: [String: String] = ["":""]
                    self.getUser(succes: { userJson in
                        user = userJson
                        print("getUserSucces user")
                        print(user)
                        print("login user")
                        print(user)
                        success(user)
                    })
                }
            }
        }
        task.resume()
    }
    
    // TODO : Ajouter user en base locale
    func signUpOnServer(phone: String, password: String, firstname: String, lastname: String, mail: String, profile: String, gravatar: String, success: @escaping () -> (), failure: @escaping () -> ()) {
        var json = [String:String]()
        json["phone"] = phone
        json["password"] = password
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        json["gravatar"] = gravatar
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
                if let responseJSON = responseJSON as? [String:String]{
                    if let message = responseJSON["message"]{
                        print(message)
                        failure()
                        return
                    }
                }
                print("user valide donc envoi mdp")
                success()
            }
        }
        task.resume()
    }
    
    // TODO : Renvoyer la liste reçue
    func getContacts(){
        guard let token: String = self.token else{
            print("Le token n'est pas défini")
            return
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
                let managerDB = ManageDbProvider.sharedInstance
                managerDB.fillCoreDataWithContacts(json: resp)
                //return resp
            }
        }
        task.resume()
    }
    
    // TODO : Que faire en cas de suppression
    func deleteContact(id: String, token: String, success: @escaping ()->(), failure: @escaping()->()){
        let urlString = API_URL + protectedModifier + "/contacts/" + id
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            do {
                guard error == nil else {
                    print(error?.localizedDescription ?? "error")
                    failure()
                    return
                }
                success()
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    //TODO : tester l'update
    func updateContact(phone: String, firstname: String, lastname: String, mail: String, profile: String, gravatar: String,emergency: Bool, id: String,user: User, token: String, success: @escaping ()->(), failure: @escaping()->() ){
        var json = [String:Any]()
        json["phone"] = phone
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        json["gravatar"] = gravatar
        json["isFamilinkUser"] = emergency
        json["isEmergencyUser"] = emergency
        let urlString = API_URL + protectedModifier + "/contacts/"+id;
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
                    failure()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]{
                    if let message = responseJSON["message"]{
                        print(message)
                        failure()
                        return
                    }
                }
                print("Contact modifié")
                success()
            }
        }
        task.resume()
    }
    
    func getUser(succes: @escaping([String: String]) -> ()){
        let urlString = API_URL + protectedModifier + "/current";
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        guard let token = self.token else{
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let userJson = responseJSON as? [String: String]{
                    print("getUser user :")
                    print(userJson)
                    succes(userJson)
                }
            }
        }
        task.resume()
    }
    
    func createContact(phone: String, firstname: String, lastname: String, mail: String, profile: String, gravatar: String,emergency: Bool,user: User, token: String, success: @escaping ()->(), failure:@escaping()->() ){
        var json = [String:Any]()
        json["phone"] = phone
        json["firstName"] = firstname
        json["lastName"] = lastname
        json["email"] = mail
        json["profile"] = profile
        json["gravatar"] = gravatar
        json["isFamilinkUser"] = emergency
        json["isEmergencyUser"] = emergency
        let urlString = API_URL + protectedModifier+"/contacts"
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let task = session.dataTask(with: request){data, response, error in
            do{
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    failure()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any]{
                    if let message = responseJSON["message"]{
                        print(message)
                        return
                    } else{
                    print("Contact créé")
                    success()
                    }
                }
            }
        }
        task.resume()
    }
    
    func getProfiles(success: @escaping ([String])->(), failure: @escaping()->()) -> (){
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
                    failure()
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
    
    
    // INUTILISE
    
//    func isTokenValid()->Bool{
//        let payload = token?.components(separatedBy: ".")[1]
//
//        //base64 encoded string i want to decode
//        guard var base64String = payload else{
//            return false
//        }
//        print(base64String) //eyJleHAiOjE0MjY4MjIxNjMsImlkIjoiNTUwYjA3NzM4ODk1NjAwZTk5MDAwMDAxIn0
//        if base64String.count % 4 != 0 {
//            let padlen = 4 - base64String.count % 4
//            //base64String += String(count: padlen, repeated: Character("="))
//            base64String += String(repeatElement("=", count: padlen))
//        }
//
//        //attempting to convert base64 string to nsdata
//        let decodedData = NSData(base64Encoded: base64String, options:NSData.Base64DecodingOptions(rawValue: NSData.Base64DecodingOptions.RawValue(0)))
//        print(decodedData)
//        let decodedString = NSString(data: decodedData as! Data, encoding: String.Encoding.utf8.rawValue)
//        print(decodedString)
//        var expString = decodedString?.components(separatedBy: ":")[3]
//        expString = expString?.trimmingCharacters(in: ["}"])
//        guard let stringExp = expString else{
//            return false
//        }
//        guard let exp = Double(stringExp) else{
//            return false
//        }
//        print(Date().timeIntervalSince1970)
//        return Date().timeIntervalSince1970 < exp
//    }

}
