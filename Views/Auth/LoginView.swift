import SwiftUI

/// Écran de connexion de l'application.
struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        @Bindable var auth = viewModel
        
        NavigationStack {
            ZStack {
                // Fond transparent pour laisser voir le hublot racine
                Color.clear.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("ResSync")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.majorelleBlue)
                        
                        Text("Votre voisin de trajet vous attend.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $auth.email)
                            .padding()
                            .background(.white.opacity(0.8))
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Mot de passe", text: $auth.password)
                            .padding()
                            .background(.white.opacity(0.8))
                            .cornerRadius(12)
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    
                    Button(action: { 
                        Task { await viewModel.signIn() } 
                    }) {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Se connecter")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.majorelleBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .majorelleBlue.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .disabled(viewModel.isLoading)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Pas encore de compte ? **S'inscrire**")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .background(Color.clear)
    }
}
