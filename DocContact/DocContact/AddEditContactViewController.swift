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
    let DBManager = ManageDbProvider.sharedInstance
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var emergencyUserSwitch: UISwitch!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func mailVerifRealTime(_ sender: Any) {
        guard let mailText = emailTextField.text else {
            return
        }
        if !DataValidation.isMailValid(mail: mailText){
            self.setBorderRed(textfield: emailTextField)
        } else {
            self.resetBorder(textfield: emailTextField)
        }
    }
    @IBAction func phoneVerifRealTime(_ sender: Any) {
        guard let number = phoneTextField.text else{
            return
        }
        if !DataValidation.isPhoneValid(phone: number){
            self.setBorderRed(textfield: phoneTextField)
        } else {
            self.resetBorder(textfield: phoneTextField)
        }
    }
    @IBAction func editLastName(_ sender: Any) {
        self.resetBorder(textfield: nameTextField)    }
    @IBAction func editFirstName(_ sender: Any) {
        self.resetBorder(textfield: firstNameTextField)
    }
    @IBAction func editProfile(_ sender: Any) {
        self.resetBorder(textfield: pickerTextField)
    }
    
    var pickOption = [""]
    let pickerView = UIPickerView()
    var isInEditionMode:Bool = true
    var contact : Contact?
    var user: User?
    
    func fillPickerOptions(){
        netProvider.getProfiles(success:{ profiles in
            self.pickOption = profiles
        }, failure:{
            //TODO: Alerte reconnexion
        })
    }
    
    func setBorderRed(textfield: UITextField){
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.red.cgColor
    }
    func resetBorder(textfield: UITextField){
        textfield.layer.borderWidth = 0.0
        textfield.layer.borderColor = UIColor.clear.cgColor
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
        user = DBManager.getUser()
        
        
        if isInEditionMode {
            // Set the title with correct parameters
            self.title = NSLocalizedString("Edit", comment: "")
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
            nameTextField.text = contact?.lastName
            firstNameTextField.text = contact?.firstName
            phoneTextField.text = contact?.phone
            emailTextField.text = contact?.email
            guard let emergency = contact?.isEmergencyUser else{
                return
            }
            emergencyUserSwitch.setOn(emergency, animated: false)
            pickerTextField.text = contact?.profile
            //TODO: Pré-remplir les données
        } else {
            // Set the title with correct parameters
            self.title = NSLocalizedString("Add", comment: "")
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
            pickerTextField.text = "SENIOR"
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
        }
        
        //TextField:
        nameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
        //PickerView:
        pickerView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(editContact))
        
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
        if !DataValidation.isLastNameValid(lastName: name){
            self.setBorderRed(textfield: nameTextField)
            valid = false
        }
        
        guard let firstname = firstNameTextField.text else{
            return
        }
        if !DataValidation.isFirstNameValid(firstName: firstname){
            self.setBorderRed(textfield: firstNameTextField)
            valid = false
        }
        
        guard let phone = phoneTextField.text else{
            return
        }
        if !DataValidation.isPhoneValid(phone: phone){
            self.setBorderRed(textfield: phoneTextField)
            valid = false
        }
        
        guard let mail = emailTextField.text else{
            return
        }
        if !DataValidation.isMailValid(mail: mail){
            self.setBorderRed(textfield: emailTextField)
            valid = false
        }
        let gravatar = self.getGravatar(mail: mail)
        
        guard let profile = pickerTextField.text else{
            return
        }
        if !DataValidation.isProfileValid(profile: profile){
            valid = false
            self.setBorderRed(textfield: pickerTextField)
        }
        let emergency = emergencyUserSwitch.isOn
        
        if valid{
            guard let token = netProvider.token else{
                return
            }
            guard let user = self.user else{
                return
            }
            if !self.isInEditionMode{
                // Create contact
                netProvider.createContact(phone: phone, firstname: firstname, lastname: name, mail: mail, profile: profile, gravatar: gravatar, emergency: emergency,user: user, token: token, success: {
                    DispatchQueue.main.async {
                        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
                        let navVC = UINavigationController(rootViewController: contactVC)
                        self.present(navVC, animated: true, completion: nil)
                    }
                }, failure:{
                    self.alertConnectError()
                })
            } else {
                guard let id = contact?.id else{
                    return
                }
                
                // Update contact
                netProvider.updateContact(phone: phone, firstname: firstname, lastname: name, mail: mail, profile: profile, gravatar: gravatar, emergency: emergency,id:id,user: user, token: token, success: {DispatchQueue.main.async {
                    let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
                    let navVC = UINavigationController(rootViewController: contactVC)
                    self.present(navVC, animated: true, completion: nil)
                    }
                }, failure:{
                    self.alertConnectError()
                })
            }
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
        guard let token = netProvider.token, let id = contact?.id else{
            return
        }
        let alertDelelete = UIAlertController(title: NSLocalizedString("Confirmation", comment: ""), message : NSLocalizedString("DeleteConfirmation", comment: ""), preferredStyle: .alert )
        alertDelelete.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        alertDelelete.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (alertDelete) in
            self.deletetOnServer(id: id, token: token)
        }))
        self.present(alertDelelete, animated: true, completion: nil)
    }
    
    func deletetOnServer(id: String, token: String){
        self.netProvider.deleteContact(id: id, token: token, success: {
            DispatchQueue.main.async {
                let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
                let navVC = UINavigationController(rootViewController: contactVC)
                self.present(navVC, animated: true, completion: nil)
            }
        },failure:{
            self.alertConnectError()
        })
        
    }
    
    func alertChamps(){
        let alertSignUp = UIAlertController(title: NSLocalizedString("InscriptionError", comment: ""), message: "Veuillez vérifier les champs surlignés", preferredStyle: .alert)
        alertSignUp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertSignUp, animated: true, completion: nil)
    }
    func alertConnectError(){
        let alertConnection = UIAlertController(title: NSLocalizedString("ConnectionError", comment: ""), message: NSLocalizedString("ConnectErrorMessage", comment: ""), preferredStyle: .alert)
        alertConnection.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:{alertConnection in
            self.alertReconnect()}))
        alertConnection.addAction(UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: UIAlertActionStyle.cancel,handler: nil))
        self.present(alertConnection, animated: true, completion: {
        })
    }
    func alertReconnect(){
        guard let phone = user?.phone else {
            return
        }
        var passwordTextField: UITextField?
        let alertPassword = UIAlertController(title: "Reconnect", message: "Reconnect Message", preferredStyle: .alert)
        alertPassword.addTextField(configurationHandler: {(pass)->() in
            passwordTextField = pass
            passwordTextField?.isSecureTextEntry=true
        })
        alertPassword.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertPassword) in
            guard let password = passwordTextField?.text else{
                return
            }
            self.netProvider.loginOnServer(phone: phone, password: password, success: { _ in }, failure: {})
        }))
        alertPassword.addAction(UIAlertAction(title: "Retour", style: .cancel, handler: nil))
        self.present(alertPassword, animated: true, completion: nil)
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
