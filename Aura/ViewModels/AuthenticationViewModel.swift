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
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            self.errorMessage = "Veuillez remplir tous les champs"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Création de l'URL pour l'API locale
        guard let url = URL(string: "http://localhost:8080/api/auth/login") else {
            self.errorMessage = "URL d'API invalide"
            self.isLoading = false
            return
        }
        
        // Préparation des données d'authentification
        let loginData = ["email": username, "password": password]
        
        do {
            // Conversion des données en JSON
            let jsonData = try JSONSerialization.data(withJSONObject: loginData, options: [])
            
            // Configuration de la requête
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // Exécution de la requête
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    // Gestion des erreurs de réseau
                    if let error = error {
                        self?.errorMessage = "Erreur de connexion: \(error.localizedDescription)"
                        return
                    }
                    
                    // Vérification de la réponse HTTP
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.errorMessage = "Réponse invalide du serveur"
                        return
                    }
                    
                    // Vérification du code de statut
                    switch httpResponse.statusCode {
                    case 200...299:
                        // Authentification réussie
                        guard let data = data else {
                            self?.errorMessage = "Données de réponse manquantes"
                            return
                        }
                        
                        do {
                            // Parsing de la réponse JSON
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let token = json["token"] as? String {
                                // Stockage du token pour une utilisation ultérieure
                                UserDefaults.standard.set(token, forKey: "authToken")
                                
                                // Notification de connexion réussie
                                self?.onLoginSucceed()
                            } else {
                                self?.errorMessage = "Format de réponse invalide"
                            }
                        } catch {
                            self?.errorMessage = "Erreur de parsing JSON: \(error.localizedDescription)"
                        }
                        
                    case 401:
                        self?.errorMessage = "Identifiants invalides"
                    case 500...599:
                        self?.errorMessage = "Erreur serveur, veuillez réessayer plus tard"
                    default:
                        self?.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))"
                    }
                }
            }
            
            task.resume()
            
        } catch {
            isLoading = false
            errorMessage = "Erreur de préparation des données: \(error.localizedDescription)"
        }
    }
} 