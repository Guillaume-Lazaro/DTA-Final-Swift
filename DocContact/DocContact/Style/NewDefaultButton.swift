//
//  NewDefaultButton.swift
//  DocContact
//
//  Created by Thomas on 01/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit


class NewDefaultButton : UIButton{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.backgroundColor = UIColor.init(red: 114.0/255.0, green: 147.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        self.setTitleColor( UIColor.white, for: .selected)
        
    }
    
    override var isHighlighted: Bool {
        willSet {
            print(newValue)
            if(newValue){
                self.backgroundColor =  UIColor.init(red: 44.0/255.0, green: 56.0/255.0, blue: 165.0/255.0, alpha: 1.0)
            }
        }
    }
}
