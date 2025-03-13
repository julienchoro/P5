//
//  AllTransactionsView.swift
//  Aura
//
//  Created by Julien Choromanski on 03/03/2025.
//

import SwiftUI

struct AllTransactionsView: View {
    @ObservedObject var viewModel: AllTransactionsViewModel
    
    var body: some View {
        ZStack {
            // Contenu principal
            VStack(spacing: 0) {
                // Liste des transactions
                if viewModel.transactions.isEmpty && !viewModel.isLoading {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Aucune transaction à afficher")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            viewModel.fetchTransactions()
                        }) {
                            Text("Rafraîchir")
                                .padding()
                                .background(Color(hex: "#94A684"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchTransactions()
                    }
                }
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
        .navigationTitle("Toutes les Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchTransactions()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
    }
}

// Ligne de transaction réutilisable
struct TransactionRow: View {
    let transaction: TransactionViewModel
    
    var body: some View {
        HStack {
            Image(systemName: transaction.isCredit ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundColor(transaction.isCredit ? .green : .red)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                
                Text(transaction.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.amount)
                .fontWeight(.bold)
                .foregroundColor(transaction.isCredit ? .green : .red)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        AllTransactionsView(viewModel: AllTransactionsViewModel())
    }
} 
