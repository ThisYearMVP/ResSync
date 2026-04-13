import SwiftUI

/// Écran du profil de l'utilisateur connecté.
struct MyProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("\(viewModel.age) ans, \(viewModel.nationality)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Ma Bio") {
                    Text(viewModel.bio.isEmpty ? "Aucune bio renseignée" : viewModel.bio)
                }
                
                Section("Paramètres") {
                    NavigationLink("Modifier mon profil", destination: ProfileSetupView())
                    Button("Se déconnecter", role: .destructive) {
                        try? FirebaseService.shared.signOut()
                    }
                }
            }
            .navigationTitle("Mon Profil")
        }
    }
}
