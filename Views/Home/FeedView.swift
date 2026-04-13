import SwiftUI

/// Écran du flux de profils avec swipe.
struct FeedView: View {
    let searchTrip: Trip
    @State private var viewModel = FeedViewModel()
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Recherche des voyageurs...")
            } else if viewModel.matchingUsers.isEmpty {
                ContentUnavailableView("Personne sur ce trajet", systemImage: "person.3.sequence", description: Text("Réessayez plus tard ou changez vos critères."))
            } else {
                ZStack {
                    ForEach(viewModel.matchingUsers) { user in
                        ProfileCardView(user: user)
                            .zIndex(Double(viewModel.matchingUsers.firstIndex(of: user) ?? 0))
                            .offset(x: user == viewModel.matchingUsers.last ? offset.width : 0)
                            .rotationEffect(.degrees(user == viewModel.matchingUsers.last ? Double(offset.width / 10) : 0))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        handleSwipe(width: gesture.translation.width, user: user)
                                    }
                            )
                    }
                }
            }
        }
        .navigationTitle("\(searchTrip.origin) → \(searchTrip.destination)")
        .task {
            await viewModel.loadMatches(for: searchTrip)
        }
    }
    
    private func handleSwipe(width: CGFloat, user: User) {
        if width > 150 {
            // Swipe Droite : Like
            withAnimation(.spring()) {
                offset.width = 500
            }
            viewModel.likeUser(user)
        } else if width < -150 {
            // Swipe Gauche : Skip
            withAnimation(.spring()) {
                offset.width = -500
            }
            viewModel.skipUser(user)
        } else {
            // Retour au centre
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
}
