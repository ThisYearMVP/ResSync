import SwiftUI

struct ContentView: View {
    @Binding var phase: Int
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    
    var body: some View {
        Group {
            if !supabaseService.isInitialLoadComplete {
                ZStack {
                    Color.clear
                    ProgressView("Vérification...")
                        .tint(.majorelleBlue)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                .transition(.opacity)
            } else if !supabaseService.isAuthenticated {
                // ÉCHANGE CONDITIONNEL : Pas de NavigationStack pour la transition Login -> Menu
                LoginView()
                    .background(Color.clear)
                    .transition(.opacity)
                    .onAppear { phase = 1 } // Reset phase pour le login
            } else {
                // MENU PRINCIPAL
                ZStack {
                    Color.clear
                    
                    TabView(selection: $selectedTab) {
                        MyProfileView()
                            .background(Color.clear)
                            .tag(0)
                        
                        MyTripsListView()
                            .id(tripsRefreshID)
                            .background(Color.clear)
                            .tag(1)
                        
                        TripSearchView(onTripAdded: {
                            tripsRefreshID = UUID()
                            selectedTab = 1
                        })
                        .background(Color.clear)
                        .tag(2)
                    }
                    .background(Color.clear)
                    .tabViewStyle(.page(indexDisplayMode: .never)) // Style page pour fluidité
                }
                .transition(.opacity)
                .onChange(of: selectedTab) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.6)) {
                        phase = newValue
                    }
                }
                .onAppear {
                    // Initialise la phase avec l'onglet par défaut
                    phase = selectedTab
                }
            }
        }
    }
}

// Composant partagé pour les tags d'intérêt
struct InterestTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.majorelleBlue : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
