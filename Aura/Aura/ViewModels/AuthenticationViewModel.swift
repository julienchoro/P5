//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    // Validation de l'email
    func isValidEmail() -> Bool {
        return ValidationUtils.isValidEmail(username)
    }
    
    // Fonction de login
    func login() {
        // Vérification que l'email est valide
        guard isValidEmail() else {
            errorMessage = "Veuillez entrer une adresse email valide"
            showError = true
            return
        }
        
        // Vérification que le mot de passe n'est pas vide
        guard !password.isEmpty else {
            errorMessage = "Veuillez entrer un mot de passe"
            showError = true
            return
        }
        
        // Indication de chargement
        isLoading = true
        errorMessage = ""
        showError = false
        
        // Création de la requête d'authentification
        let authRequest = AuthenticationRequest(username: username, password: password)
        
        // Appel à l'API d'authentification
        Task {
            do {
                // Appel à l'API via le service réseau
                let response: AuthenticationResponse = try await NetworkService.shared.post(endpoint: "auth", body: authRequest)
                
                // Stockage du token d'authentification
                NetworkService.shared.setAuthToken(response.token)
                
                // Mise à jour de l'UI sur le thread principal
                await MainActor.run {
                    isLoading = false
                    // Appel du callback de succès
                    onLoginSucceed()
                }
            } catch let error as NetworkError {
                await handleNetworkError(error)
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Une erreur inattendue s'est produite"
                    showError = true
                }
            }
        }
    }
    
    // Gestion des erreurs réseau
    @MainActor
    private func handleNetworkError(_ error: NetworkError) {
        isLoading = false
        
        switch error {
        case .badRequest:
            errorMessage = "Identifiants incorrects"
        case .unauthorized:
            errorMessage = "Non autorisé"
        case .serverError:
            errorMessage = "Erreur serveur"
        case .invalidURL:
            errorMessage = "URL invalide"
        case .invalidResponse:
            errorMessage = "Réponse invalide"
        case .requestFailed(let underlyingError):
            errorMessage = "Erreur de requête: \(underlyingError.localizedDescription)"
        case .decodingFailed(let underlyingError):
            errorMessage = "Erreur de décodage: \(underlyingError.localizedDescription)"
        }
        
        showError = true
    }
}
