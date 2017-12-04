//
//  InscriptionViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class InscriptionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    let netProvider = NetworkProvider.sharedInstance
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBAction func verifPhoneRealTime(_ sender: Any) {
        guard let phone = phoneTextField.text else{
            return
        }
        if DataValidation.isPhoneValid(phone: phone){
            self.resetBorder(textfield: phoneTextField)
        } else {
            self.setBorderRed(textfield: phoneTextField)
        }
    }
    @IBAction func verifMailRealTime(_ sender: Any) {
        guard let mail = emailTextField.text else{
            return
        }
        if DataValidation.isMailValid(mail: mail){
            self.resetBorder(textfield: emailTextField)
        } else{
            self.setBorderRed(textfield: emailTextField)
        }
    }
    @IBAction func verifPasswordRealTime(_ sender: Any) {
        guard let pass = passwordTextField.text else{
            return
        }
        if DataValidation.isPasswordValid(password: pass){
            self.resetBorder(textfield: passwordTextField)
        } else {
            self.setBorderRed(textfield: passwordTextField)
        }
    }
    @IBAction func verifConfirmRealTime(_ sender: Any) {
        guard let pass = passwordTextField.text, let confirm = confirmPasswordTextField.text else{
            return
        }
        if DataValidation.isConfirmValid(confirm: confirm, password: pass){
            self.resetBorder(textfield: confirmPasswordTextField)
        } else {
            self.setBorderRed(textfield: confirmPasswordTextField)
        }
    }
    @IBAction func editlastName(_ sender: Any) {
        self.resetBorder(textfield: nameTextField)
    }
    @IBAction func editFirstName(_ sender: Any) {
        self.resetBorder(textfield: firstNameTextField)
    }
    
    /*func isPhoneValid(phone: String)->Bool{
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phone, options: [], range: NSMakeRange(0, phone.count))
            if let res = matches.first {
                let result = res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone.count
                print("Phone OK")
                return result
            } else {
                print("Phone not OK")
                return false
            }
        } catch {
            print(error)
        }
        return false;
    }*/
    /*func isMailValid(mail: String)->Bool{
        let mailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let test = NSPredicate(format: "SELF MATCHES %@", mailRegEx)
        return test.evaluate(with: mail)
    }*/
    /*func isPasswordValid(pass: String)->Bool{
        return pass.count == 4
    }*/
    func setBorderRed(textfield: UITextField){
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.red.cgColor
    }
    func resetBorder(textfield: UITextField){
        textfield.layer.borderWidth = 0.0
        textfield.layer.borderColor = UIColor.clear.cgColor
    }
    
    
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
        
  
        // Change the navBar color
        self.title = NSLocalizedString("Inscription", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]

        
        //TextField:
        nameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        //PickerView:
        pickerView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(validateInscription))
        
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
        if checkInputText(firstname: firstname, lastname: lastname, phone: phone, mail: mail, password: password, profile: profile){
            self.netProvider.signUpOnServer(phone: phone, password: password, firstname: firstname, lastname: lastname, mail: mail, profile: profile, success: {
                self.netProvider.loginOnServer(phone: phone, password: password, success: {
                    DispatchQueue.main.async {
                        let alertWelcome = UIAlertController(title: NSLocalizedString("InscriptionSuccess", comment: ""), message: NSLocalizedString("Welcome", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alertWelcome.addAction(UIAlertAction(title:NSLocalizedString("Begin", comment: ""), style: UIAlertActionStyle.default, handler: {
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
            self.alertFailed()
        }
    }
    
    func checkInputText(firstname: String, lastname: String, phone: String, mail: String, password: String, profile: String) -> Bool{
        if checkName(firstname: firstname, lastname: lastname) && checkNum(phone: phone) && checkMail(email: mail) && checkPassword(password: password) && checkProfile(profile: profile) {
            return true
        }else{
            return false
        }
    }
    
    func checkName(firstname: String, lastname: String) -> Bool{
        if firstname.isEmpty || lastname.isEmpty {
            let alertName = UIAlertController(title: NSLocalizedString("InscriptionError", comment: ""), message:NSLocalizedString("CheckName", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertName.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler:nil))
            self.present(alertName, animated: true, completion: nil)
            return false
        }else{
            return true
        }
    }
    
    func checkMail(email: String)-> Bool{
        if DataValidation.isMailValid(mail: email) {
            return true
        }else{
            let alertMail = UIAlertController(title: NSLocalizedString("MailError", comment: ""), message:NSLocalizedString("CheckMail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertMail.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler:nil))
            self.present(alertMail, animated: true, completion: nil)
            return false
        }
    }
    
    func checkNum(phone: String) -> Bool{
        if DataValidation.isPhoneValid(phone: phone) {
            let alertCount = UIAlertController(title: NSLocalizedString("InscriptionError", comment: ""), message:NSLocalizedString("CheckPhone", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertCount.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler:nil))
            self.present(alertCount, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func checkPassword(password: String) -> Bool{
        if DataValidation.isPasswordValid(password: password){
            let alertCountPwd = UIAlertController(title: NSLocalizedString("PasswordError", comment: ""), message:NSLocalizedString("CheckPassword", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
            alertCountPwd.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style:UIAlertActionStyle.default, handler:nil))
            self.present(alertCountPwd, animated: true, completion: nil)
            return false
        } else{
            if password != confirmPasswordTextField.text{
                self.setBorderRed(textfield: confirmPasswordTextField)
                self.alertPwd()
                return false
            }
        }
        return true
    }
    
    func checkProfile(profile: String) -> Bool{
        if profile == "_"{
            let alertProfile = UIAlertController(title: NSLocalizedString("ProfileError", comment: ""), message:NSLocalizedString("CheckProfile", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertProfile.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler:nil))
            self.present(alertProfile, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func goToList(){
        let contactVC = ContactListTableViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func alertPwd(){
        let alertMdp = UIAlertController(title: NSLocalizedString("PasswordError", comment: ""), message:
            NSLocalizedString("CheckPasswordConfirm", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alertMdp.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertMdp, animated: true, completion: nil)
        
    }
    
    func alertFailed(){
        let alertSignUp = UIAlertController(title: NSLocalizedString("InscriptionError", comment: ""), message: NSLocalizedString("AlreadyUsedPhone", comment: ""), preferredStyle: .alert)
        alertSignUp.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default,handler: nil))
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
}
