//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = "€0.00"
    @Published var recentTransactions: [TransactionViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // Nombre maximum de transactions récentes à afficher
    private let maxRecentTransactions = 3
    
    // Toutes les transactions récupérées depuis l'API
    private var allTransactions: [AccountResponse.Transaction] = []
    
    init() {
        // Chargement des données au démarrage
        fetchAccountData()
    }
    
    // Récupération des données du compte depuis l'API
    func fetchAccountData() {
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                // Appel à l'API via le service réseau
                let response: AccountResponse = try await NetworkService.shared.get(endpoint: "account")
                
                // Sauvegarde de toutes les transactions
                self.allTransactions = response.transactions
                
                // Mise à jour de l'UI sur le thread principal
                await MainActor.run {
                    // Mise à jour du solde total
                    self.totalAmount = response.formattedBalance
                    
                    // Mise à jour des transactions récentes (limitées à maxRecentTransactions)
                    self.updateRecentTransactions()
                    
                    self.isLoading = false
                }
            } catch let error as NetworkError {
                await handleNetworkError(error)
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Une erreur inattendue s'est produite"
                    self.showError = true
                }
            }
        }
    }
    
    // Mise à jour des transactions récentes
    private func updateRecentTransactions() {
        // Prendre les N premières transactions
        let recentTransactions = allTransactions.prefix(maxRecentTransactions)
        
        // Conversion en TransactionViewModel
        self.recentTransactions = recentTransactions.map { transaction in
            TransactionViewModel(
                description: transaction.label,
                amount: transaction.formattedAmount,
                isCredit: transaction.isCredit
            )
        }
    }
    
    // Gestion des erreurs réseau
    @MainActor
    private func handleNetworkError(_ error: NetworkError) {
        isLoading = false
        
        switch error {
        case .unauthorized:
            errorMessage = "Session expirée, veuillez vous reconnecter"
            // Rediriger vers l'écran de connexion
            NetworkService.shared.clearAuthToken()
            // Ici, vous pourriez notifier l'application pour rediriger vers l'écran de connexion
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
        case .badRequest:
            errorMessage = "Requête invalide"
        }
        
        showError = true
    }
    
    // Modèle de vue pour les transactions
    struct TransactionViewModel: Identifiable {
        let id = UUID()
        let description: String
        let amount: String
        let isCredit: Bool
    }
}
