//
//  LightBlueButton.swift
//  DocContact
//
//  Created by Thomas on 01/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit


class LightBlueButton : UIButton{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.backgroundColor = UIColor.init(red: 114.0/255.0, green: 147.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        self.setTitleColor( UIColor.init(red: 65.0/255.0, green: 75.0/255.0, blue: 168.0/255.0, alpha: 1.0), for: .highlighted)
        
    }
    
}
