//
//  DetailViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit
import MessageUI

protocol DetailViewControllerDelegate: AnyObject {
    func deleteContact()
}

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var imageView: RoundedImage!
    @IBOutlet weak var phoneView: UILabel!
    @IBOutlet weak var emailView: UILabel!
    @IBOutlet weak var typeView: UILabel!
    @IBOutlet weak var emergencyUserView: UILabel!
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    
    weak var contact: Contact?
    weak var delegate: DetailViewControllerDelegate?
    
    //variables pour afficher le profil de l'utilisateur
    var user: User?
    let DBManager = ManageDbProvider.sharedInstance
    var isContactsDetails: Bool = false
    
    // TODO : Gérer si on veut afficher les détails du profil et non d'un contact
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Au cas ou, si le contact n'est pas donné en paramétre, on indique qu'il s'agit de Mon Profil:
        if contact == nil {
            isContactsDetails = true
        } else {
            isContactsDetails = false
        }
        
        // si on veut afficher le profil, on récupère l'user en cours
        if !isContactsDetails{
            self.user=self.DBManager.getUser()
        }

        // Set the title with correct parameters
        self.title = NSLocalizedString("MyContact", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
        
        fillTheFields()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Modify", comment: ""), style: .plain, target: self, action: #selector(goToEditContact))
        
        //Changement de l'image de profil:
        guard let hashGravatar:String = self.contact?.gravatar else {
            return
        }
        DispatchQueue.main.async() {
            let strUrl = hashGravatar+"?s=200&d=mm"
            print("URL: ",strUrl)
            let url = URL(string: strUrl)
            let data = try? Data(contentsOf: url!)
            self.imageView.image = UIImage(data: data!)
        }
    }
  
    @IBAction func pressedCallButton(_ sender: Any) {
        guard let phone = self.contact?.phone else{
            return
        }
        let url: NSURL = URL(string: "TEL://\(phone)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    @IBAction func pressedSendMail(_ sender: Any) {
        guard let mail = contact?.email else{
            return
        }
  
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["\(mail)"])
            composeVC.setSubject( NSLocalizedString("Greetings", comment: ""))
            composeVC.setMessageBody(NSLocalizedString("MailFromDocContacts", comment: ""), isHTML: false)
            
            // Present the view controller modally.
            present(composeVC, animated: true)
            
            
        } else {
            print("Mail services are not available")
            return
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        
        controller.dismiss(animated: true)
    }
    
    @objc func goToEditContact(){
        let contactVC = AddEditContactViewController(nibName: nil, bundle: nil)
        contactVC.contact = contact
        contactVC.isInEditionMode = true   //On précise à la view AddEdit qu'il s'agit d'une édition
        self.navigationController?.pushViewController(contactVC, animated: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillTheFields(){
        phoneView.text = contact?.phone
        emailView.text = contact?.email
        typeView.text = contact?.profile
        guard let firstName = contact?.firstName, let lastName = contact?.lastName else{
            print("Les noms ne sont pas valides")
            return
        }
        let firstAndLastName = "\(lastName) \(firstName)"
        firstAndLastNameLabel.text = firstAndLastName
        
    }
    
}

extension String {
    func toMD5()  -> String {
        if let messageData = self.data(using:String.Encoding.utf8) {
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            
            _ = digestData.withUnsafeMutableBytes {digestBytes in
                messageData.withUnsafeBytes {messageBytes in
                    CC_MD5(messageBytes, CC_LONG((messageData.count)), digestBytes)
                }
            }
            return digestData.hexString()
        }
        return self
    }
}

extension Data {
    func hexString() -> String {
        let string = self.map{ String($0, radix:16) }.joined()
        return string
    }
}
