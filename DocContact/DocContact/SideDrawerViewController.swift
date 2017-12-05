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
        self.dismiss(animated: true, completion: nil)
    }
}
