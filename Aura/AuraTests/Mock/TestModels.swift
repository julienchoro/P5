//
//  TestModels.swift
//  Aura
//
//  Created by Julien Choromanski on 09/03/2025.
//

import Foundation

// Structure pour les tests de requêtes POST
struct TestRequestModel: Codable {
    let username: String
    let password: String
    
    static func mockLoginRequest() -> TestRequestModel {
        return TestRequestModel(username: "test@aura.app", password: "test123")
    }
}

// Structure pour les tests de réponses
struct TestResponseModel: Codable {
    let id: Int
    let message: String
    let success: Bool
    
    static func mockSuccessResponse() -> TestResponseModel {
        return TestResponseModel(id: 1, message: "Opération réussie", success: true)
    }
    
    static func mockErrorResponse() -> TestResponseModel {
        return TestResponseModel(id: 0, message: "Échec de l'opération", success: false)
    }
}

// Structure pour les tests d'authentification
struct AuthResponse: Codable {
    let token: String
    let userId: Int
    
    static func mockAuthResponse() -> AuthResponse {
        return AuthResponse(token: "93D2C537-FA4A-448C-90A9-6058CF26DB29", userId: 42)
    }
}

// Structure pour les tests de données de compte
struct AccountResponse: Codable {
    let currentBalance: Decimal
    let transactions: [Transaction]
    
    struct Transaction: Codable {
        let value: Decimal
        let label: String
    }
}

// Structure pour les tests de transfert d'argent
struct TransferRequest: Codable {
    let amount: Decimal
    let recipient: String
    
    static func mockValidTransfer() -> TransferRequest {
        return TransferRequest(amount: 100.0, recipient: "John Doe")
    }
    
    static func mockInvalidTransfer() -> TransferRequest {
        return TransferRequest(amount: -50.0, recipient: "John Doe")
    }
}
