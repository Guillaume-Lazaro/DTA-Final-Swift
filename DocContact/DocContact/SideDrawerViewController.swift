//
//  SideDrawerViewController.swift
//  DocContact
//
//  Created by Thomas on 04/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit
import CoreData

class SideDrawerViewController: UIViewController {

    let netProvider = NetworkProvider.sharedInstance
    let DBManager = ManageDbProvider.sharedInstance
    var resultController : NSFetchedResultsController<User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToProfil(_ sender: Any) {
        let profilVC = DetailViewController(nibName: nil, bundle: nil)
        profilVC.isContactsDetails = false
        self.navigationController?.pushViewController(profilVC, animated: true)
    }

    
    @IBAction func disconnect(_ sender: Any) {
        netProvider.token = nil
        DBManager.deleteUsersFromCoreData()
        //let loginVC = LoginViewController(nibName: nil, bundle: nil)
        //self.navigationController?.popToViewController(, animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
}
