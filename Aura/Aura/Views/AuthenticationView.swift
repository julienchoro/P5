//
//  AuthenticationView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    @ObservedObject var viewModel: AuthenticationViewModel
    
    let gradientStart = Color(hex: "#94A684").opacity(0.7)
    let gradientEnd = Color(hex: "#94A684").opacity(0.0) // Fades to transparent
    
    var body: some View {
        
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    
                Text("Welcome !")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                TextField("Adresse email", text: $viewModel.username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .disabled(viewModel.isLoading)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                
                if viewModel.showError && !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                        .transition(.opacity)
                }
                
                Button(action: {
                    viewModel.login()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    } else {
                        Text("Se connecter")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 40)
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

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel({
        
    }))
}
