//
//  RoundedImage.swift
//  DocContact
//
//  Created by Thomas on 28/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit

class RoundedImage : UIImageView{
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        self.layer.borderWidth = 1

    }
}

