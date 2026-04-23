import SwiftUI

struct ContentView: View {
    @Binding var phase: Int
    @State private var supabaseService = SupabaseService.shared
    @State private var selectedTab = 1
    @State private var tripsRefreshID = UUID()
    
    var body: some View {
        ZStack {
            if !supabaseService.isInitialLoadComplete {
                ZStack {
                    Color.clear
                    ProgressView("Vérification...")
                        .tint(.majorelleBlue)
                }
            } else if !supabaseService.isAuthenticated {
                LoginView()
                    .background(Color.clear)
                    .onAppear { phase = 1 }
            } else {
                mainMenuView
            }
        }
        .background(Color.clear)
    }
    
    var mainMenuView: some View {
        ZStack {
            // Contenu des onglets
            TabView(selection: $selectedTab) {
                MyProfileView()
                    .tag(0)
                    .background(Color.clear)
                
                MyTripsListView()
                    .id(tripsRefreshID)
                    .tag(1)
                    .background(Color.clear)
                
                TripSearchView(onTripAdded: {
                    tripsRefreshID = UUID()
                    selectedTab = 1
                })
                .tag(2)
                .background(Color.clear)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.clear)
            
            // TabBar personnalisée (transparente)
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    tabButton(title: "Profil", icon: "person.crop.circle", tag: 0)
                    tabButton(title: "Mes Trajets", icon: "suitcase.rolling.fill", tag: 1)
                    tabButton(title: "Ajouter", icon: "plus.circle.fill", tag: 2)
                }
                .padding(.top, 10)
                .padding(.bottom, 25)
                .background(.ultraThinMaterial.opacity(0.3))
            }
            .ignoresSafeArea()
        }
        .background(Color.clear)
        .transition(.opacity)
        .onChange(of: selectedTab) { _, newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                phase = newValue
            }
        }
        .onAppear {
            phase = selectedTab
        }
    }
    
    func tabButton(title: String, icon: String, tag: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tag
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == tag ? .majorelleBlue : .gray)
        }
        .buttonStyle(.plain)
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
