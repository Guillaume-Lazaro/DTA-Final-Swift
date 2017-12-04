//
//  ViewController.swift
//  DocContact
//
//  Created by Guillaume Lazaro on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    let netProvider = NetworkProvider.sharedInstance
    let DBManager = ManageDbProvider.sharedInstance
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DBManager.deleteUsersFromCoreData()
        
        //TextField:
        phoneTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alertForgottenPassword(_ sender: Any) {
        //Création de l'alert
        let alertController = UIAlertController(title: "Mot de passe oublié", message: "Veuillez entrez votre numéro de téléphone pour récupérer votre mot de passe.", preferredStyle: .alert)
        
        //Ajout de l'input text:
        //var phoneToSendPassword:String = ""
        alertController.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.phonePad
            textField.placeholder = "Numéro de téléphone"
        }
        let cancelAction = UIAlertAction(title: "Retour", style: .cancel)
        let OK = UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] (_) in
            let textField = alertController?.textFields![0] //On sait qu'il existe (si si!)
            guard let phoneToSendPassword = textField?.text else{
                return
            }
            print("Test du textField: ", phoneToSendPassword)
            
            self.dismiss(animated: true, completion: nil)
            self.forgottenPassword(phoneNumber: phoneToSendPassword)
            
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
        netProvider.loginOnServer(phone: phone, password: password,
                                  success: { user in
                                    self.DBManager.createCoreDataUser(userJson: user)
                                    DispatchQueue.main.async {
                                    self.goToList()}
        },
                                  failure: { DispatchQueue.main.async {
                                    self.alertLoginFailed()}
        })
    }
    
    func forgottenPassword(phoneNumber: String) {
//        let alertController:UIAlertController
//                       let OK:UIAlertAction
//        
        netProvider.forgotPassword(phone: phoneNumber, success: {
            DispatchQueue.main.async{
                let alertController:UIAlertController
                let OK:UIAlertAction
                alertController = UIAlertController(title: "Mot de passe envoyé", message: "Votre mot de passe a été envoyé à l'adresse Email de votre compte", preferredStyle: .alert)

                OK = UIAlertAction(title: "OK", style: .default){ _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OK)
                self.present(alertController, animated:true)
            }
        }, failure: {DispatchQueue.main.async {
            let alertController:UIAlertController
            let OK:UIAlertAction
            alertController = UIAlertController(title: "Numéro inconnu", message: "Ce numéro est inconnu, veuillez créez un compte.", preferredStyle: .alert)

            OK = UIAlertAction(title: "OK", style: .default){ _ in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OK)
            self.present(alertController, animated:true)
            }})
        
//        if(phoneNumber == "0655545546") {
//            //L'utilisateur existe dans la bdd!
//            alertController = UIAlertController(title: "Mot de passe envoyé", message: "Votre mot de passe a été envoyé à l'adresse Email de votre compte", preferredStyle: .alert)
//
//             OK = UIAlertAction(title: "OK", style: .default){ _ in
//                self.dismiss(animated: true, completion: nil)
//            }
//        } else {
//            //L'utilisateur n'existe pas :(
//             alertController = UIAlertController(title: "Numéro inconnu", message: "Ce numéro est inconnu, veuillez créez un compte.", preferredStyle: .alert)
//
//             OK = UIAlertAction(title: "OK", style: .default){ _ in
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        alertController.addAction(OK)
//        self.present(alertController, animated:true)
    }
    
    
    func goToList(){
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func alertLoginFailed(){
        let alertLogin = UIAlertController(title: "Login échoué", message: "Nous n'avons pas pu vous connecter, vérifiez votre numéro de téléphone et votre mot de passe puis réessayez", preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default){ _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertLogin.addAction(OK)
        self.present(alertLogin, animated:true)
    }

}


