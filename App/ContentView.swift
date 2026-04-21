import SwiftUI

struct ContentView: View {
    @Binding var phase: Int
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    @State private var showRevealAnimation = true // Pour l'animation de départ
    
    var body: some View {
        ZStack {
            Group {
                if !supabaseService.isInitialLoadComplete {
                    ZStack {
                        Color.clear
                        ProgressView("Vérification...")
                            .tint(.majorelleBlue)
                    }
                } else if !supabaseService.isAuthenticated {
                    LoginView()
                        .onAppear { 
                            phase = 1 
                            showRevealAnimation = false // Pas de reveal sur le login
                        }
                } else {
                    mainMenuView
                        .onAppear { phase = selectedTab }
                }
            }
            
            // L'avion qui découvre le menu
            if supabaseService.isAuthenticated && showRevealAnimation {
                AirplaneRevealView {
                    showRevealAnimation = false
                }
                .zIndex(10)
            }
        }
    }
    
    var mainMenuView: some View {
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
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .transition(.opacity)
        .onChange(of: selectedTab) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                phase = newValue
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
