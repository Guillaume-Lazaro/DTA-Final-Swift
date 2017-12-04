//
//  ThinBorderButton.swift
//  DocContact
//
//  Created by Thomas on 04/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit


class ThinBorderButton : UIButton{    

    @IBInspectable var borderColor: UIColor? = UIColor.black {
        didSet {
            layer.borderColor = self.borderColor?.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = self.borderWidth
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor?.cgColor
    }
}

