//
//  DetailViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: RoundedImage!
    @IBOutlet weak var phoneView: UILabel!
    @IBOutlet weak var emailView: UILabel!
    @IBOutlet weak var typeView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Mon Contact"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modifier", style: .plain, target: self, action: #selector(goToEditContact))
        
        //Transformation de l'email en hash MD5:
        var email = "guillaume.lazaro@gmail.com"    //Entrez l'email de l'utilisateur ici
        email = email.lowercased()
        email = email.trimmingCharacters(in: .whitespaces)
        var hashGravatar:String = email.toMD5()
        
        //Changement de l'image de profil:
        DispatchQueue.main.async() {
            let strUrl = "https://www.gravatar.com/avatar/"+hashGravatar+"s=200"
            print("URL: ",strUrl)
            let url = URL(string: strUrl)
            let data = try? Data(contentsOf: url!)
            self.imageView.image = UIImage(data: data!)
        }
    }
    
    @objc func goToEditContact(){
        let contactVC = AddEditContactViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
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
