//
//  DetailViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func deleteContact()
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: RoundedImage!
    @IBOutlet weak var phoneView: UILabel!
    @IBOutlet weak var emailView: UILabel!
    @IBOutlet weak var typeView: UILabel!
    @IBOutlet weak var emergencyUserView: UILabel!
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    
    weak var contact: Contact?
    weak var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("le contact est ",self.contact ?? "no contact")
        // Set the title with correct parameters 
        self.title = "Mon Contact"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
        
        
        fillTheFields()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modifier", style: .plain, target: self, action: #selector(goToEditContact))
        
        //Changement de l'image de profil:
        guard let hashGravatar:String = self.contact?.gravatar else {
            return
        }
        DispatchQueue.main.async() {
            let strUrl = hashGravatar+"?s=200"
            print("URL: ",strUrl)
            let url = URL(string: strUrl)
            let data = try? Data(contentsOf: url!)
            self.imageView.image = UIImage(data: data!)
        }
    }
    
    @objc func goToEditContact(){
        let contactVC = AddEditContactViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        contactVC.contact = contact
        contactVC.isInEditionMode = true   //On précise à la view AddEdit qu'il s'agit d'une édition
        self.present(navVC, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillTheFields(){
        phoneView.text = contact?.phone
        emailView.text = contact?.email
        typeView.text = contact?.profile
        guard let firstName = contact?.firstName as? String, let lastName = contact?.lastName as? String else{
            print("Les noms ne sont pas valides")
            return
        }
        let firstAndLastName = "\(lastName) \(firstName)"
        firstAndLastNameLabel.text = firstAndLastName
        
        // TODO : gérer le emergency + gravatar
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
