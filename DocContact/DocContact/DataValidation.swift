//
//  DataValidation.swift
//  DocContact
//
//  Created by Benjamin LOUIS on 01/12/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import Foundation
class DataValidation{
    static func isMailValid(mail: String)->Bool{
        let mailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let test = NSPredicate(format: "SELF MATCHES %@", mailRegEx)
        if test.evaluate(with:mail){
            return true
        } else {
            return false
        }
    }
    static func isPhoneValid(phone: String)->Bool{
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phone, options: [], range: NSMakeRange(0, phone.count))
            if let res = matches.first {
                let result = res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone.count
                print("Phone OK")
                return result
            } else {
                print("Phone not OK")
                return false
            }
        } catch {
            print(error)
        }
        return false;
    }
    static func isPasswordValid(password: String)->Bool{
        return password.count == 4
    }
    static func isFirstNameValid(firstName : String)->Bool{
        return !firstName.isEmpty
    }
    static func isLastNameValid(lastName: String)->Bool{
        return !lastName.isEmpty
    }
    static func isConfirmValid(confirm: String, password: String)->Bool{
        return self.isPasswordValid(password: password) && self.isPasswordValid(password: confirm) && password == confirm
    }
    static func isProfileValid(profile: String)->Bool{
        return !profile.isEmpty
    }
}
