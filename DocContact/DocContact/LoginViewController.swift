//
//  ViewController.swift
//  DocContact
//
//  Created by Guillaume Lazaro on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    weak var delegate: LoginViewControllerDelegate?
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func navToInscription(_ sender: Any) {
        // Setting up the nav
        let contactVC = InscriptionViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func navToContactList(_ sender: Any) {
        // Setting up the nav
        guard let phone: String = phoneTextField.text, let password: String = passwordTextField.text else {
            return
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            appDelegate.loginOnServer(phone: phone, password: password)
        }
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
}
protocol LoginViewControllerDelegate : AnyObject{
    func login(phone: String, password: String)
}

