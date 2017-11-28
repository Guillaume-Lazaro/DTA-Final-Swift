//
//  RoundedButton.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton : UIButton{
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1
        let myColor : UIColor = UIColor(red:0.76, green:0.217, blue:0.1, alpha:1.0)
        self.layer.borderColor = myColor.cgColor
        
    }
}
