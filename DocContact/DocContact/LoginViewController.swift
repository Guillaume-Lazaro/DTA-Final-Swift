//
//  ViewController.swift
//  DocContact
//
//  Created by Guillaume Lazaro on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
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
    @IBAction func alertForgottenPassword(_ sender: Any) {
        //TODO : Alert forgotten password
        
        let alertController = UIAlertController(title: "Mot de passe oublié", message: "Cette fenêtre est à modifier pour permettre de récupérer le mot de passe", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Retour", style: .cancel)
        let OK = UIAlertAction(title: "OK", style: .default){ _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OK)
        
        self.present(alertController, animated:true)
        
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


