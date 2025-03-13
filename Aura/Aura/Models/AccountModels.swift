//
//  AccountModels.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

// Modèle pour la réponse de l'API concernant les informations du compte
struct AccountResponse: Codable {
    let currentBalance: Decimal
    let transactions: [Transaction]
    
    struct Transaction: Codable, Identifiable {
        let value: Decimal
        let label: String
        
        // Ajout d'un identifiant unique pour faciliter l'utilisation avec SwiftUI
        var id: String {
            return UUID().uuidString
        }
        
        // Formatage du montant pour l'affichage
        var formattedAmount: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "€"
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            
            let formattedValue = formatter.string(from: NSDecimalNumber(decimal: abs(value))) ?? "0.00"
            return value >= 0 ? "+\(formattedValue)" : "-\(formattedValue)"
        }
        
        // Indique si la transaction est un crédit (valeur positive)
        var isCredit: Bool {
            return value >= 0
        }
    }
    
    // Formatage du solde pour l'affichage
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSDecimalNumber(decimal: currentBalance)) ?? "€0.00"
    }
}

// Modèle pour la requête de transfert
struct AccountTransferRequest: Codable {
    let recipient: String
    let amount: Decimal
} 
