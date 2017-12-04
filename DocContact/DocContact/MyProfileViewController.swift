//
//  MyProfileViewController.swift
//  DocContact
//
//  Created by Thomas on 04/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit
import CoreData

class MyProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title with correct parameters
        self.title = NSLocalizedString("Mon Profil", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
        
        // Do any additional setup after loading the view.
        
        let fetchRequestUser = NSFetchRequest<User>(entityName : "User")
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchedUser = try managedContext.fetch(fetchRequestUser)
            print(fetchedUser)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
