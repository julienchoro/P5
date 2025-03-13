//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var isSuccess: Bool = false
    
    // Référence au vue-modèle du compte pour pouvoir rafraîchir les données
    private let accountViewModel: AccountDetailViewModel?
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    // Initialisation avec une référence optionnelle au vue-modèle du compte
    init(accountViewModel: AccountDetailViewModel? = nil) {
        self.accountViewModel = accountViewModel
    }
    
    private func isValidAmount(_ amount: String) -> Bool {
        // Nettoie la chaîne des symboles monétaires
        let cleanedAmount = amount.replacingOccurrences(of: "€", with: "").trimmingCharacters(in: .whitespaces)
        
        // Essaie d'abord avec le formateur de devise
        if let number = currencyFormatter.number(from: cleanedAmount) {
            return number.doubleValue > 0
        }
        
        // Si ça ne marche pas, essaie de convertir directement la chaîne en Double
        if let number = Double(cleanedAmount.replacingOccurrences(of: ",", with: ".")) {
            return number > 0
        }
        
        return false
    }
    
    // Convertit la chaîne de montant en Decimal
    private func amountToDecimal(_ amount: String) -> Decimal? {
        // Nettoie la chaîne des symboles monétaires
        let cleanedAmount = amount.replacingOccurrences(of: "€", with: "").trimmingCharacters(in: .whitespaces)
        
        // Essaie d'abord avec le formateur de devise
        if let number = currencyFormatter.number(from: cleanedAmount) {
            return number.decimalValue
        }
        
        // Si ça ne marche pas, essaie de convertir directement la chaîne en Decimal
        if let number = Double(cleanedAmount.replacingOccurrences(of: ",", with: ".")) {
            return Decimal(number)
        }
        
        return nil
    }
    
    func sendMoney() {
        // Réinitialisation des états
        transferMessage = ""
        isLoading = false
        showError = false
        isSuccess = false
        
        if recipient.isEmpty || amount.isEmpty {
            transferMessage = "Veuillez renseigner le destinataire et le montant"
            showError = true
            return
        }
        
        // Vérifie d'abord si le destinataire est valide
        if !ValidationUtils.isValidRecipient(recipient) {
            transferMessage = "Veuillez entrer un e-mail ou un numéro de téléphone français valide"
            showError = true
            return
        }
        
        // Vérifie ensuite si le montant est valide
        if !isValidAmount(amount) {
            transferMessage = "Veuillez entrer un montant valide"
            showError = true
            return
        }
        
        // Convertit le montant en Decimal
        guard let decimalAmount = amountToDecimal(amount) else {
            transferMessage = "Erreur lors de la conversion du montant"
            showError = true
            return
        }
        
        // Création de la requête de transfert
        let transferRequest = AccountTransferRequest(recipient: recipient, amount: decimalAmount)
        
        // Indication de chargement
        isLoading = true
        
        // Appel à l'API de transfert
        Task {
            do {
                // Appel à l'API via le service réseau en utilisant une méthode personnalisée
                // qui ne tente pas de décoder la réponse
                try await sendTransferRequest(transferRequest)
                
                // Mise à jour de l'UI sur le thread principal
                await MainActor.run {
                    isLoading = false
                    isSuccess = true
                    
                    // Formatage du montant pour l'affichage
                    if let formattedAmount = currencyFormatter.string(from: NSDecimalNumber(decimal: decimalAmount)) {
                        transferMessage = "Transfert de \(formattedAmount) effectué avec succès vers \(recipient)"
                    } else {
                        transferMessage = "Transfert effectué avec succès vers \(recipient)"
                    }
                    
                    // Réinitialisation des champs
                    self.recipient = ""
                    self.amount = ""
                    
                    // Rafraîchir les données du compte après un transfert réussi
                    self.refreshAccountData()
                }
            } catch let error as NetworkError {
                await handleNetworkError(error)
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError = true
                    transferMessage = "Une erreur inattendue s'est produite"
                }
            }
        }
    }
    
    // Méthode pour rafraîchir les données du compte
    private func refreshAccountData() {
        // Si nous avons une référence au vue-modèle du compte, rafraîchir les données
        accountViewModel?.fetchAccountData()
        
        // Rafraîchir également les données dans AllTransactionsViewModel si nécessaire
        // Cela nécessiterait une notification ou un mécanisme similaire
        NotificationCenter.default.post(name: NSNotification.Name("RefreshTransactions"), object: nil)
    }
    
    // Méthode personnalisée pour envoyer la requête de transfert sans tenter de décoder la réponse
    private func sendTransferRequest(_ transferRequest: AccountTransferRequest) async throws {
        // Utilisation d'une implémentation personnalisée pour éviter les problèmes de décodage
        do {
            // Création de l'URL
            guard let url = URL(string: "http://localhost:8080/account/transfer") else {
                throw NetworkError.invalidURL
            }
            
            // Création de la requête
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Ajout du token d'authentification
            if let token = NetworkService.shared.getAuthToken() {
                request.addValue(token, forHTTPHeaderField: "token")
            } else {
                throw NetworkError.unauthorized
            }
            
            // Encodage du corps de la requête
            request.httpBody = try JSONEncoder().encode(transferRequest)
            
            // Exécution de la requête
            let (_, response) = try await URLSession.shared.data(for: request)
            
            // Vérification de la réponse HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Vérification du code de statut
            switch httpResponse.statusCode {
            case 200...299:
                // Succès, pas besoin de décoder la réponse
                return
            case 400:
                throw NetworkError.badRequest
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError
            }
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
    
    // Gestion des erreurs réseau
    @MainActor
    private func handleNetworkError(_ error: NetworkError) {
        isLoading = false
        showError = true
        
        switch error {
        case .unauthorized:
            transferMessage = "Session expirée, veuillez vous reconnecter"
            // Rediriger vers l'écran de connexion
            NetworkService.shared.clearAuthToken()
        case .serverError:
            transferMessage = "Erreur serveur"
        case .invalidURL:
            transferMessage = "URL invalide"
        case .invalidResponse:
            transferMessage = "Réponse invalide"
        case .requestFailed(let underlyingError):
            transferMessage = "Erreur de requête: \(underlyingError.localizedDescription)"
        case .decodingFailed(let underlyingError):
            transferMessage = "Erreur de décodage: \(underlyingError.localizedDescription)"
        case .badRequest:
            transferMessage = "Requête invalide. Vérifiez les informations saisies."
        }
    }
}
