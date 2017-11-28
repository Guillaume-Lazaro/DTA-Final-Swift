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
    @IBAction func alertForgottenPassword(_ sender: Any) {
        //Création de l'alert
        let alertController = UIAlertController(title: "Mot de passe oublié", message: "Veuillez entrez votre numéro de téléphone pour récupérer votre mot de passe.", preferredStyle: .alert)
        
        //Ajout de l'input text:
        var phoneToSendPassword:String = ""
        alertController.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.phonePad
            textField.placeholder = "Numéro de téléphone"
        }
        let cancelAction = UIAlertAction(title: "Retour", style: .cancel)
        let OK = UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] (_) in
            let textField = alertController?.textFields![0] //On sait qu'il existe (si si!)
            print("Test du textField: ", textField?.text)
            
            self.dismiss(animated: true, completion: nil)
            self.forgottenPassword(phoneNumber: (textField?.text)!)
            
        })
        
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
    
    func forgottenPassword(phoneNumber: String) {
        let alertController:UIAlertController
        let OK:UIAlertAction
        if(phoneNumber == "0655545546") {
            //L'utilisateur existe dans la bdd!
            alertController = UIAlertController(title: "Mot de passe envoyé", message: "Votre mot de passe a été envoyé à l'adresse Email de votre compte", preferredStyle: .alert)
            
            OK = UIAlertAction(title: "OK", style: .default){ _ in
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            //L'utilisateur n'existe pas :(
            alertController = UIAlertController(title: "Numéro inconnu", message: "Ce numéro est inconnu, veuillez créez un compte.", preferredStyle: .alert)
            
            OK = UIAlertAction(title: "OK", style: .default){ _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(OK)
        self.present(alertController, animated:true)
    }
}
protocol LoginViewControllerDelegate : AnyObject{
    func login(phone: String, password: String)
}

