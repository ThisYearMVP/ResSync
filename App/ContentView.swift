import SwiftUI

struct ContentView: View {
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    @State private var phase = 1 // Variable d'état pour l'animation du fond
    
    var body: some View {
        Group {
            if !supabaseService.isInitialLoadComplete {
                ZStack {
                    AirplaneWindowBackground(selection: 1)
                        .ignoresSafeArea()
                    ProgressView("Vérification...")
                        .tint(.majorelleBlue)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
            } else if !supabaseService.isAuthenticated {
                LoginView()
            } else {
                ZStack {
                    // COUCHE INFÉRIEURE : Arrière-plan animé
                    AirplaneWindowBackground(selection: phase)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.6), value: phase)
                    
                    // COUCHE SUPÉRIEURE : Contenu
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
                    .onAppear {
                        // Règle de transparence UITabBar
                        let appearance = UITabBarAppearance()
                        appearance.configureWithTransparentBackground()
                        appearance.backgroundColor = UIColor.clear
                        UITabBar.appearance().standardAppearance = appearance
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
                .tint(.majorelleBlue)
                .onChange(of: selectedTab) { _, newValue in
                    // Piloter l'animation du fond
                    phase = newValue
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
                .background(isSelected ? Color.majorelleBlue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
