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
        print("Le bouton call a été appuyé")
    }
   
    var gravatarHash : String? {
        didSet {
            //task?.cancel()
            self.downloadGravatar()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func downloadGravatar() {
        guard let hashString = gravatarHash else {
            return
        }
        DispatchQueue.main.async() {
            let strUrl = hashString
            print("URL: ",strUrl)
            let url = URL(string: strUrl)
            let data = try? Data(contentsOf: url!)
            self.profileImageView.image = UIImage(data: data!)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
