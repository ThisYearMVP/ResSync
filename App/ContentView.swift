import SwiftUI

struct ContentView: View {
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    
    var body: some View {
        Group {
            if !supabaseService.isInitialLoadComplete {
                ZStack {
                    AirplaneWindowBackground()
                    ProgressView("Vérification de la session...")
                        .tint(.majorelleBlue)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
            } else if !supabaseService.isAuthenticated {
                LoginView()
            } else {
                ZStack {
                    // Fond global glissant
                    AirplaneWindowBackground(selection: selectedTab)
                    
                    TabView(selection: $selectedTab) {
                        MyProfileView()
                            .tabItem {
                                Label("Profil", systemImage: "person.crop.circle")
                            }
                            .tag(0)
                        
                        MyTripsListView()
                            .id(tripsRefreshID)
                            .tabItem {
                                Label("Mes Trajets", systemImage: " suitcase.rolling.fill")
                            }
                            .tag(1)
                        
                        TripSearchView(onTripAdded: {
                            tripsRefreshID = UUID() // Force le rafraîchissement
                            selectedTab = 1
                        })
                        .tabItem {
                            Label("Ajouter", systemImage: "plus.circle.fill")
                        }
                        .tag(2)
                    }
                    .scrollContentBackground(.hidden) // Cache les fonds par défaut
                }
                .tint(.majorelleBlue)
                .onAppear {
                    // Suppression radicale des fonds système pour la transparence
                    let appearance = UITabBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = .clear
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    
                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithTransparentBackground()
                    navAppearance.backgroundColor = .clear
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                    
                    // Force la transparence des vues de collection/table si existantes
                    UITableView.appearance().backgroundColor = .clear
                    UITableViewCell.appearance().backgroundColor = .clear
                }
                .animation(.spring(), value: selectedTab)
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
