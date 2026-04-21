import SwiftUI

/// Écran du profil de l'utilisateur connecté.
struct MyProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        VStack {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.majorelleBlue.opacity(0.8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.name)
                                        .font(.title2.bold())
                                    Text("\(viewModel.age) ans, \(viewModel.nationality)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.7))
                        .cornerRadius(20)
                        
                        // Bio Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ma Bio")
                                .font(.headline)
                                .foregroundColor(.majorelleBlue)
                            Text(viewModel.bio.isEmpty ? "Aucune bio renseignée" : viewModel.bio)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.white.opacity(0.7))
                        .cornerRadius(20)
                        
                        // Actions Section
                        VStack(spacing: 12) {
                            NavigationLink(destination: ProfileSetupView()) {
                                HStack {
                                    Label("Modifier mon profil", systemImage: "pencil")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(.white.opacity(0.7))
                                .cornerRadius(15)
                            }
                            .buttonStyle(.plain)
                            
                            Button(role: .destructive) {
                                Task { try? await SupabaseService.shared.signOut() }
                            } label: {
                                HStack {
                                    Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                                    Spacer()
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Mon Profil")
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}
