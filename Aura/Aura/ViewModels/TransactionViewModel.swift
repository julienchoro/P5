//
//  TransactionViewModel.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

// Modèle de vue pour une transaction
struct TransactionViewModel: Identifiable {
    let id = UUID()
    let description: String
    let amount: String
    let isCredit: Bool
    let date: String
    let rawDate: Date // Date brute conservée pour l'affichage chronologique
} 