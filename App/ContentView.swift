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
                    // 1. Fond global (doit être tout en bas)
                    AirplaneWindowBackground(selection: selectedTab)
                        .ignoresSafeArea()
                    
                    // 2. TabView avec style de page pour le glissement continu
                    TabView(selection: $selectedTab) {
                        MyProfileView()
                            .tag(0)
                        
                        MyTripsListView()
                            .id(tripsRefreshID)
                            .tag(1)
                        
                        TripSearchView(onTripAdded: {
                            tripsRefreshID = UUID()
                            selectedTab = 1
                        })
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                    
                    // 3. TabBar personnalisée
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            tabButton(title: "Profil", icon: "person.crop.circle", tag: 0)
                            tabButton(title: "Mes Trajets", icon: "suitcase.rolling.fill", tag: 1)
                            tabButton(title: "Ajouter", icon: "plus.circle.fill", tag: 2)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 25)
                        .background(.ultraThinMaterial.opacity(0.8))
                    }
                    .ignoresSafeArea()
                }
                .background(Color.clear)
                .onAppear {
                    UINavigationBar.appearance().backgroundColor = .clear
                    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
                    UINavigationBar.appearance().shadowImage = UIImage()
                }
            }
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
