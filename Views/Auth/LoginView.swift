import SwiftUI

/// Écran de connexion de l'application.
struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("ResSync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: { Task { await viewModel.signIn() } }) {
                    Text(viewModel.isLoading ? "Chargement..." : "Se connecter")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                
                NavigationLink("Pas encore de compte ? S'inscrire", destination: SignUpView())
            }
            .padding()
        }
    }
}
