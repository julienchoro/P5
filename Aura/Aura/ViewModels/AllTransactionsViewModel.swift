//
//  AllTransactionsViewModel.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import Foundation

class AllTransactionsViewModel: ObservableObject {
    @Published var transactions: [TransactionViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    init() {
        fetchTransactions()
        
        // S'abonner à la notification de rafraîchissement des transactions
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshNotification), name: NSNotification.Name("RefreshTransactions"), object: nil)
    }
    
    deinit {
        // Se désabonner de la notification
        NotificationCenter.default.removeObserver(self)
    }
    
    // Méthode appelée lorsqu'une notification de rafraîchissement est reçue
    @objc private func handleRefreshNotification() {
        fetchTransactions()
    }
    
    // Récupération des transactions depuis l'API
    func fetchTransactions() {
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                // Appel à l'API via le service réseau
                let response: AccountResponse = try await NetworkService.shared.get(endpoint: "account")
                
                // Création d'un formateur de date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                dateFormatter.locale = Locale(identifier: "fr_FR")
                
                // Mise à jour de l'UI sur le thread principal
                await MainActor.run {
                    // Conversion des transactions en TransactionViewModel
                    self.transactions = response.transactions.enumerated().map { index, transaction in
                        // Création d'une date fictive pour l'affichage (car l'API ne fournit pas de date)
                        // Plus l'index est élevé, plus la transaction est ancienne
                        let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
                        let dateString = dateFormatter.string(from: date)
                        
                        return TransactionViewModel(
                            description: transaction.label,
                            amount: transaction.formattedAmount,
                            isCredit: transaction.isCredit,
                            date: dateString,
                            rawDate: date
                        )
                    }
                    
                    // Tri par date (plus récentes d'abord)
                    self.transactions.sort { $0.rawDate > $1.rawDate }
                    
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
    
    // Gestion des erreurs réseau
    @MainActor
    private func handleNetworkError(_ error: NetworkError) {
        isLoading = false
        
        switch error {
        case .unauthorized:
            errorMessage = "Session expirée, veuillez vous reconnecter"
            // Rediriger vers l'écran de connexion
            NetworkService.shared.clearAuthToken()
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
} 
