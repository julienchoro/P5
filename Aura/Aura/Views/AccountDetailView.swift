//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    @State private var navigateToAllTransactions = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Contenu principal
                ScrollView {
                    VStack(spacing: 20) {
                        // Large Header displaying total amount
                        VStack(spacing: 10) {
                            Text("Votre Solde")
                                .font(.headline)
                            Text(viewModel.totalAmount)
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(Color(hex: "#94A684")) // Using the green color you provided
                            Image(systemName: "eurosign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .foregroundColor(Color(hex: "#94A684"))
                        }
                        .padding(.top)
                        
                        // Display recent transactions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Transactions Récentes")
                                .font(.headline)
                                .padding([.horizontal])
                            
                            if viewModel.recentTransactions.isEmpty && !viewModel.isLoading {
                                Text("Aucune transaction récente")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ForEach(viewModel.recentTransactions) { transaction in
                                    HStack {
                                        Image(systemName: transaction.isCredit ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                            .foregroundColor(transaction.isCredit ? .green : .red)
                                        Text(transaction.description)
                                        Spacer()
                                        Text(transaction.amount)
                                            .fontWeight(.bold)
                                            .foregroundColor(transaction.isCredit ? .green : .red)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding([.horizontal])
                                }
                            }
                        }
                        
                        // Button to see all transactions
                        NavigationLink(destination: AllTransactionsView(viewModel: AllTransactionsViewModel())) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("Voir Toutes les Transactions")
                            }
                            .padding()
                            .background(Color(hex: "#94A684"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding([.horizontal, .bottom])
                        
                        // Bouton de rafraîchissement
                        Button(action: {
                            viewModel.fetchAccountData()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Rafraîchir")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                        .padding([.horizontal, .bottom])
                        .disabled(viewModel.isLoading)
                        
                        Spacer()
                    }
                }
                .refreshable {
                    viewModel.fetchAccountData()
                }
                
                // Indicateur de chargement
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 80, height: 80)
                        )
                }
            }
            .onTapGesture {
                self.endEditing(true)  // This will dismiss the keyboard when tapping outside
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    AccountDetailView(viewModel: AccountDetailViewModel())
}
