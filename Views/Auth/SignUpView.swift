import SwiftUI

/// Écran d'inscription de l'application.
struct SignUpView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Créer un compte")
                .font(.title)
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
            
            Button(action: { Task { await viewModel.signUp() } }) {
                Text(viewModel.isLoading ? "Inscription..." : "S'inscrire")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
