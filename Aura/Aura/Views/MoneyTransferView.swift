//
//  MoneyTransferView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct MoneyTransferView: View {
    @ObservedObject var viewModel: MoneyTransferViewModel
    @State private var animationScale: CGFloat = 1.0
    @State private var showSuccessAnimation: Bool = false

    var body: some View {
        ZStack {
            // Contenu principal
            ScrollView {
                VStack(spacing: 20) {
                    // Adding a fun header image
                    Image(systemName: "arrow.right.arrow.left.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color(hex: "#94A684"))
                        .padding()
                        .scaleEffect(animationScale)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                animationScale = 1.2
                            }
                        }
                    
                    Text("Envoyer de l'argent")
                        .font(.largeTitle)
                        .fontWeight(.heavy)

                    VStack(alignment: .leading) {
                        Text("Destinataire (Email ou Téléphone)")
                            .font(.headline)
                        TextField("Entrez l'email ou le téléphone du destinataire", text: $viewModel.recipient)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(viewModel.isLoading)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Montant (€)")
                            .font(.headline)
                        TextField("0.00", text: $viewModel.amount)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .keyboardType(.decimalPad)
                            .disabled(viewModel.isLoading)
                    }

                    Button(action: {
                        viewModel.sendMoney()
                        if viewModel.isSuccess {
                            showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSuccessAnimation = false
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Envoyer")
                            }
                        }
                        .padding()
                        .background(Color(hex: "#94A684"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.isLoading)

                    // Message
                    if !viewModel.transferMessage.isEmpty {
                        Text(viewModel.transferMessage)
                            .padding(.top, 20)
                            .foregroundColor(viewModel.showError ? .red : .green)
                            .multilineTextAlignment(.center)
                            .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            // Animation de succès
            if showSuccessAnimation {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    Text("Transfert réussi !")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.7))
                )
                .transition(.scale)
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
            Text(viewModel.transferMessage)
        }
    }
}

#Preview {
    MoneyTransferView(viewModel: MoneyTransferViewModel())
}
