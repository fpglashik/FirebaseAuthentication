//
//  String+Ext.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/17/23.
//

import Foundation

extension String {
    
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    var isEmail: Bool {
        let emailPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern)
            .evaluate(with: self)
    }
    
    var isPhoneNo: Bool {
        let phonePattern = #"(?=.{8,})"# + #"^[0-9+]{0,1}+[0-9]{5,16}$"#
        return NSPredicate(format: "SELF MATCHES %@", phonePattern)
            .evaluate(with: self)
    }
    
    var isAlphanumeric: Bool {
        let alphanumericPattern = #"^[^a-zA-Z0-9]$"#
        return NSPredicate(format: "SELF MATCHES %@", alphanumericPattern)
            .evaluate(with: self)
    }
    
    var isStrongPassword: Bool {
        let passwordPattern =
            // At least 8 characters
            #"(?=.{8,})"# +

            // At least one capital letter
            #"(?=.*[A-Z])"# +
                
            // At least one lowercase letter
            #"(?=.*[a-z])"# +
                
            // At least one digit
            #"(?=.*\d)"# +
                
            // At least one special character
            #"(?=.*[ !$%&?._-])"#
        
        return NSPredicate(format: "SELF MATCHES %@", passwordPattern)
            .evaluate(with: self)
    }
}
