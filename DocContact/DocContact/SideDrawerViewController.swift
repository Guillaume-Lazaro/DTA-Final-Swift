//
//  SideDrawerViewController.swift
//  DocContact
//
//  Created by Thomas on 04/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit
import CoreData

protocol SideDrawerViewControllerDelegate: AnyObject {
    func goToLogin()
}

class SideDrawerViewController: UIViewController {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var resultController : NSFetchedResultsController<User>!
    var user: User?
    let DBManager = ManageDbProvider.sharedInstance
    
    weak var delegate: SideDrawerViewControllerDelegate?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.user=self.DBManager.getUser()  //On récupére l'user en cours
        guard let firstName = user?.firstName else{
            return
        }
        self.firstNameLabel.text = "Bonjour \(firstName)"
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
        print("clicked")
        self.delegate?.goToLogin()
    }
}
