//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
    
    // Instances partagées des vue-modèles
    private lazy var _accountDetailViewModel = AccountDetailViewModel()
    private lazy var _allTransactionsViewModel = AllTransactionsViewModel()
    
    init() {
        isLogged = false
    }
    
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel { [weak self] in
            self?.isLogged = true
        }
    }
    
    var accountDetailViewModel: AccountDetailViewModel {
        return _accountDetailViewModel
    }
    
    var allTransactionsViewModel: AllTransactionsViewModel {
        return _allTransactionsViewModel
    }
    
    var moneyTransferViewModel: MoneyTransferViewModel {
        // Passer la référence du AccountDetailViewModel au MoneyTransferViewModel
        return MoneyTransferViewModel(accountViewModel: _accountDetailViewModel)
    }
}
