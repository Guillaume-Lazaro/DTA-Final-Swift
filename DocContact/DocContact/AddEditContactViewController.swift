//
//  AddEditContactViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class AddEditContactViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    let netProvider = NetworkProvider.sharedInstance
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var emergencyUserSwitch: UISwitch!
    @IBOutlet weak var deleteButton: UIButton!
    
    var pickOption = ["-"]
    let pickerView = UIPickerView()
    var isInEditionMode:Bool = true
    var contact : Contact?
    
    func fillPickerOptions(){
        netProvider.getProfiles(){ profiles in
            self.pickOption += profiles
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row]
        pickerTextField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillPickerOptions()
        
        //TEST PRINT
        print("Le contact reçu par le Modify ", contact)
        
        if isInEditionMode {
            self.title = "Edition du contact"
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
            //TODO: Pré-remplir les données
        } else {
            self.title = "Ajouter un contact"
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(editContact))
        
        
        
        //TextField:
        nameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
        //PickerView:
        pickerView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(editContact))
        
        pickerTextField.inputView = pickerView
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // Method of the back button
    @objc func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editContact(){
        var valid: Bool = true
        // vérification des champs
        guard let name = nameTextField.text else{
            return
        }
        if name == ""{
            valid = false
        }
        
        guard let firstname = firstNameTextField.text else{
            return
        }
        if firstname == ""{
            valid = false
        }
        
        guard let phone = phoneTextField.text else{
            return
        }
        if phone == ""{
            valid = false
        }
        
        guard let mail = emailTextField.text else{
            return
        }
        if mail == ""{
            valid = false
        }
        let gravatar = self.getGravatar(mail: mail)
        
        guard let profile = pickerTextField.text else{
            return
        }
        if profile == ""{
            valid = false
        }
        let emergency = emergencyUserSwitch.isOn
        
        if valid{
            guard let token = netProvider.token else{
            return
            }
            if !self.isInEditionMode{
                netProvider.createContact(phone: phone, firstname: firstname, lastname: name, mail: mail, profile: profile, gravatar: gravatar, emergency: emergency, token: token)
            } else {
                // TODO : gérer via l'id du contact en cours (pas en dur)
                netProvider.updateContact(phone: phone, firstname: firstname, lastname: name, mail: mail, profile: profile, gravatar: gravatar, emergency: emergency,id:"5a1ebbe3bcee2b07a5b5b575", token: token)
            }
            
            let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
            let navVC = UINavigationController(rootViewController: contactVC)
            self.present(navVC, animated: true, completion: nil)
        }else{
            alertChamps()
        }
    }
    func getGravatar(mail: String)->String{
        var email = mail.lowercased()
        email = email.trimmingCharacters(in: .whitespaces)
        let mailmd5 = email.toMD5()
        let gravatar = "https://www.gravatar.com/avatar/"+mailmd5
        return gravatar
    }
    @IBAction func deleteContact(_ sender: Any) {
        guard let token = netProvider.token else{
            return
        }
        // TODO : faire en fonction de l'id du contact en cours
        // TODO : revenir à la liste
        netProvider.deleteContact(id: "5a1ebbe3bcee2b07a5b5b575", token: token)
        
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func alertChamps(){
        let alertSignUp = UIAlertController(title: "Erreur d'inscription", message: "Veuillez remplir tous les champs", preferredStyle: .alert)
        alertSignUp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertSignUp, animated: true, completion: nil)
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
