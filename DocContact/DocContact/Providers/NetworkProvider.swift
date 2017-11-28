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
    
}

