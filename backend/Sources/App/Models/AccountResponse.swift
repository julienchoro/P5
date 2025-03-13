//
//  AccountResponse.swift
//  
//
//  Created by Vincent Saluzzo on 03/10/2023.
//

import Vapor

struct AccountResponse: Content {
    let currentBalance: Decimal
    let transactions: [Transaction]
}

extension AccountResponse {
    struct Transaction: Content {
        let value: Decimal
        let label: String
    }
}
