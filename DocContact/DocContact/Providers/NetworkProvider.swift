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
    
    class var sharedInstance: NetworkProvider {
        return sharedNetServices
    }
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
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
            // TODO : vérifier réponse serveur(response)
            // TODO : si erreur-> notifier
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
                    print(token)
                    success()
                }
            }
        }
        task.resume()
    }
    
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
                if let responseJSON = responseJSON as? [String: Any]{
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

    func getContacts(){
            let urlString = API_URL + protectedModifier + "/contacts"
            let url = URL(string: urlString)!
            let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwaG9uZSI6IjA2MDAwMDAwMDIiLCJpYXQiOjE1MTE4ODU2NzksImV4cCI6MTUxMTg4NTk3OX0.xj-vi0gtproD5mWbM574douNDuYXfgdQB6rbVsqjbe0"
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
                    
                }
            }
            task.resume()
        }

}
