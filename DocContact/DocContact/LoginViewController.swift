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
    }
    
    @IBAction func alertForgottenPassword(_ sender: Any) {
        //Création de l'alert
        let alertController = UIAlertController(title: NSLocalizedString("ForgotPassword", comment: ""), message: NSLocalizedString("EnterPhoneNumber", comment: ""), preferredStyle: .alert)
        
        //Ajout de l'input text:
        
        alertController.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.phonePad
            textField.placeholder = NSLocalizedString("PhoneNumber", comment: "")
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: .cancel)
        let OK = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { [weak alertController] (_) in
            let textField = alertController?.textFields![0] //On sait qu'il existe (si si!)
            guard let phoneToSendPassword = textField?.text else{
                return
            }
            
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
       
        netProvider.forgotPassword(phone: phoneNumber, success: {
            DispatchQueue.main.async{
                let alertController:UIAlertController
                let OK:UIAlertAction
                alertController = UIAlertController(title: NSLocalizedString("PasswordSent", comment: ""), message: NSLocalizedString("YourPasswordWasSent", comment: ""), preferredStyle: .alert)

                OK = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default){ _ in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OK)
                self.present(alertController, animated:true)
            }
        }, failure: {DispatchQueue.main.async {
            let alertController:UIAlertController
            let OK:UIAlertAction
            alertController = UIAlertController(title: NSLocalizedString("UnknownPhone", comment: ""), message: NSLocalizedString("CreateAnAccount", comment: ""), preferredStyle: .alert)

            OK = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default){ _ in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OK)
            self.present(alertController, animated:true)
            }})
        
    }
    
    func goToList(){
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func alertLoginFailed(){
        let alertLogin = UIAlertController(title: NSLocalizedString("LoginFailed", comment: ""), message: NSLocalizedString("CheckYourLogin", comment: ""), preferredStyle: .alert)
        let OK = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default){ _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertLogin.addAction(OK)
        self.present(alertLogin, animated:true)
    }
    
}


