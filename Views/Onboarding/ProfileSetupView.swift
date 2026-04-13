import SwiftUI

/// Écran pour configurer son profil initialement.
struct ProfileSetupView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Informations de base") {
                TextField("Prénom", text: $viewModel.name)
                Stepper("Âge : \(viewModel.age)", value: $viewModel.age, in: 18...100)
                TextField("Nationalité", text: $viewModel.nationality)
            }
            
            Section("À propos de vous") {
                TextEditor(text: $viewModel.bio)
                    .frame(height: 100)
            }
            
            Section("Centres d'intérêt") {
                // Pour simplifier, on utilise un champ texte séparé par des virgules
                Text("Séparez vos intérêts par une virgule")
                    .font(.caption)
            }
            
            Button("Enregistrer mon profil") {
                Task {
                    await viewModel.saveProfile()
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .bold()
        }
        .navigationTitle("Configuration du profil")
    }
}
