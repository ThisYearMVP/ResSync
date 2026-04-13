import SwiftUI

struct ContentView: View {
    @State private var supabaseService = SupabaseService.shared
    
    var body: some View {
        Group {
            if !supabaseService.isAuthenticated {
                LoginView()
            } else {
                TabView {
                    TripSearchView()
                        .tabItem {
                            Label("Voyage", systemImage: "airplane.departure")
                        }
                    
                    MatchesListView()
                        .tabItem {
                            Label("Matches", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                    
                    MyProfileView()
                        .tabItem {
                            Label("Mon Profil", systemImage: "person.circle")
                        }
                }
                .tint(.blue)
            }
        }
    }
}
