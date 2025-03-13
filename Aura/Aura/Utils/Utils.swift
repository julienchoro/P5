//
//  ValidationUtils.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

struct ValidationUtils {
    static func isValidRecipient(_ recipient: String) -> Bool {
        return isValidEmail(recipient) || isValidFrenchPhoneNumber(recipient)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidFrenchPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^(?:(?:\\+|00)33|0)\\s*[1-9](?:[\\s.-]*\\d{2}){4}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}
