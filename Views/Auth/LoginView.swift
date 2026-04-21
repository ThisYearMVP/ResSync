import SwiftUI

/// Écran de connexion de l'application.
struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        // On crée une référence Bindable explicite
        @Bindable var auth = viewModel
        
        NavigationStack {
            VStack(spacing: 20) {
                Text("ResSync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $auth.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Mot de passe", text: $auth.password)
                    .textFieldStyle(.roundedBorder)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: { 
                    Task { 
                        // Appel de la méthode originale
                        await viewModel.signIn() 
                    } 
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
