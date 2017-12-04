//
//  ContactTableViewCell.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: RoundedImage!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var callButton: RoundedButton!
    
    @IBAction func callButtonPressed(_ sender: Any) {
        guard let phone = phoneNumber else {
            return
        }
        self.makeAcall(phoneNumber: phone)
    }
    
    //Numéro de téléphone:
    var phoneNumber : String?
   
    var gravatarHash : String? {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                //task?.cancel()    //TODO : Ajouter la task en attribut
                self.downloadGravatar()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code 
    }

    func makeAcall(phoneNumber: String){
        let url: NSURL = URL(string: "TEL://\(phoneNumber)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    func downloadGravatar() {
        guard let hashString = gravatarHash else {
            return
        }
        
        let strUrl = hashString+"?d=mm"
        let url = URL(string: strUrl)
        let data = try? Data(contentsOf: url!)
        DispatchQueue.main.async {
            self.profileImageView.image = UIImage(data: data!)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
