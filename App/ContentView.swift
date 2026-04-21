import SwiftUI

struct ContentView: View {
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    
    var body: some View {
        Group {
            if !supabaseService.isAuthenticated {
                LoginView()
            } else {
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
                .tint(.majorelleBlue)
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
