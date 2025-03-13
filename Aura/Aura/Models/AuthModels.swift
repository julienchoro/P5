//
//  AuthModels.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

// Modèle pour la requête d'authentification
struct AuthenticationRequest: Codable {
    let username: String
    let password: String
}

// Modèle pour la réponse d'authentification
struct AuthenticationResponse: Codable {
    let token: String
} 