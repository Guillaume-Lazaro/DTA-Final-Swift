//
//  InscriptionViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class InscriptionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    let netProvider = NetworkProvider.sharedInstance
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pickerTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var pickOption = ["_"]
    
    let pickerView = UIPickerView()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        self.title = "Inscription"
        
        //TextField:
        nameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        //PickerView:
        pickerView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Valider", style: .plain, target: self, action: #selector(validateInscription))
        
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
    
    @objc func validateInscription(){
        //TODO: validation of the inscription
        guard let phone: String = phoneTextField.text, let password: String = passwordTextField.text, let firstname: String = firstNameTextField.text, let lastname: String = nameTextField.text, let mail: String = emailTextField.text, let profile: String = pickerTextField.text else {
            return
        }
        if password == confirmPasswordTextField.text && firstNameTextField.text != "" {
            self.netProvider.signUpOnServer(phone: phone, password: password, firstname: firstname, lastname: lastname, mail: mail, profile: profile, success: {
                self.netProvider.loginOnServer(phone: phone, password: password, success: {
                    DispatchQueue.main.async {
                        let alertWelcome = UIAlertController(title: "Inscription réussie", message: "Bienvenue dans votre annuaire", preferredStyle: UIAlertControllerStyle.alert)
                        alertWelcome.addAction(UIAlertAction(title:"Commençons", style: UIAlertActionStyle.default, handler: {
                            alert -> Void in
                            
                            self.goToList()
                        }))
                        self.present(alertWelcome, animated: true)
                    }
                }, failure: {})
            },failure: { DispatchQueue.main.async {
                self.alertFailed()}
            })
        } else {
            if firstNameTextField.text == "" {
                self.alertFailed()
            }else{
                self.alertPwd()
            }
        }
    }
    
    func goToList(){
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func alertPwd(){
        let alertMdp = UIAlertController(title: "Erreur Mot de pase", message:
            "Confirmation mot de passe incorrecte", preferredStyle: UIAlertControllerStyle.alert)
        alertMdp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertMdp, animated: true, completion: nil)
        
    }
    
    func alertFailed(){
        let alertSignUp = UIAlertController(title: "Erreur d'inscription", message: "Veillez à remplir correctement tous les champs", preferredStyle: .alert)
        alertSignUp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertSignUp, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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


