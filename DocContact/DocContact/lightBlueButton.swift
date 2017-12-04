//
//  lightBlueButton.swift
//  DocContact
//
//  Created by Thomas on 01/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit

class lightBlueButton : UIButton{
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.backgroundColor = UIColor.init(red: 65, green: 75, blue: 168, alpha: 1)
    }
}
