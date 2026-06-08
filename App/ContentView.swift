import SwiftUI

struct ContentView: View {
    @Binding var phase: Int
    @State private var supabase = SupabaseService.shared
    @State private var selectedTab = 1

    var body: some View {
        ZStack {
            if !supabase.isInitialLoadComplete {
                splashView
            } else if !supabase.isAuthenticated {
                LoginView()
                    .transition(.opacity)
                    .onAppear { phase = 1 }
            } else {
                mainView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: supabase.isAuthenticated)
        .background(Color.clear)
    }

    // MARK: - Splash

    private var splashView: some View {
        VStack(spacing: 16) {
            Image(systemName: "train.side.front.car")
                .font(.system(size: 48))
                .foregroundColor(.white)
            Text("ResSync")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Navigation principale (3 tabs swipe)

    private var mainView: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MyTripsScreen()
                    .tag(0).background(Color.clear)

                AddTripScreen(onTripAdded: { selectedTab = 0 })
                    .tag(1).background(Color.clear)

                ProfileScreen()
                    .tag(2).background(Color.clear)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.clear)

            // Tab bar custom
            VStack {
                Spacer()
                RSTabBar(selected: $selectedTab)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(Color.clear)
        .onChange(of: selectedTab) { _, v in
            withAnimation(.easeInOut(duration: 0.5)) { phase = v }
        }
        .onAppear { phase = selectedTab }
    }
}

// MARK: - Tab bar

struct RSTabBar: View {
    @Binding var selected: Int

    private let items: [(icon: String, label: String)] = [
        ("suitcase.rolling.fill", "Mes Trajets"),
        ("plus.circle.fill",      "Ajouter"),
        ("person.crop.circle",    "Profil"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selected = i }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: items[i].icon)
                            .font(.system(size: selected == i ? 22 : 20, weight: selected == i ? .semibold : .regular))
                            .scaleEffect(selected == i ? 1.1 : 1.0)
                        Text(items[i].label)
                            .font(.system(size: 10, weight: selected == i ? .semibold : .regular))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selected == i ? .white : .white.opacity(0.45))
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial.opacity(0.4))
        .animation(.spring(response: 0.3), value: selected)
    }
}

// MARK: - Composant tag intérêt (partagé)

struct InterestTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption).fontWeight(.medium)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(isSelected ? Color.majorelleBlue : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
