//
//  DiscreteButton.swift
//  DocContact
//
//  Created by Thomas on 01/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
import UIKit


class DiscreteButton : UIButton{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width/2
        self.layer.cornerRadius = self.frame.height/2
        self.backgroundColor = UIColor.DocColors.blue
        self.setTitleColor( UIColor.white, for: .selected)
        self.layer.borderWidth = 1.0
        let bgBlue = UIColor.DocColors.lightBlue
        self.layer.borderColor = bgBlue.cgColor
        
    }
    
    override var isHighlighted: Bool {
        willSet {
            print(newValue)
            if(newValue){
                self.backgroundColor =  UIColor.DocColors.darkBlue
            }
        }
    }
}
