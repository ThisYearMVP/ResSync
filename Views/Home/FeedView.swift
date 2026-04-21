import SwiftUI

struct FeedView: View {
    let searchTrip: Trip
    @State private var viewModel = FeedViewModel()
    @State private var offset: CGSize = .zero
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // Header rapide
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(searchTrip.origin) → \(searchTrip.destination)")
                        .fontWeight(.semibold)
                    Text("\(searchTrip.transport.rawValue) • \(searchTrip.activity.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Placeholder pour équilibre
                Circle().fill(.clear).frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Recherche de voyageurs...")
                Spacer()
            } else if viewModel.matchingUsers.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "Plus de voyageurs",
                    systemImage: "person.3.sequence",
                    description: Text("Nous n'avons trouvé personne d'autre sur ce trajet pour le moment.")
                )
                Spacer()
            } else {
                ZStack {
                    // Les cartes sont empilées, on ne peut manipuler que celle du dessus
                    ForEach(viewModel.matchingUsers.reversed()) { user in
                        ProfileCardView(user: user)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            // Uniquement la carte du dessus répond aux gestes
                            .offset(x: user == viewModel.matchingUsers.first ? offset.width : 0)
                            .rotationEffect(.degrees(user == viewModel.matchingUsers.first ? Double(offset.width / 15) : 0))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if user == viewModel.matchingUsers.first {
                                            offset = gesture.translation
                                        }
                                    }
                                    .onEnded { gesture in
                                        if user == viewModel.matchingUsers.first {
                                            handleSwipe(width: gesture.translation.width, user: user)
                                        }
                                    }
                            )
                            .animation(.spring(), value: offset)
                    }
                }
                .padding(.bottom, 20)
                
                // Boutons d'action rapides (Tinder Style)
                HStack(spacing: 40) {
                    Button(action: { swipeAction(direction: -500, user: viewModel.matchingUsers.first) }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(width: 64, height: 64)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button(action: { swipeAction(direction: 500, user: viewModel.matchingUsers.first) }) {
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .frame(width: 64, height: 64)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMatches(for: searchTrip)
        }
    }
    
    private func handleSwipe(width: CGFloat, user: User) {
        if width > 130 {
            swipeAction(direction: 500, user: user, isLike: true)
        } else if width < -130 {
            swipeAction(direction: -500, user: user, isLike: false)
        } else {
            offset = .zero
        }
    }
    
    private func swipeAction(direction: CGFloat, user: User?, isLike: Bool = false) {
        guard let user = user else { return }
        
        withAnimation(.spring()) {
            offset.width = direction
        }
        
        // Délai pour laisser l'animation de sortie se terminer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if isLike {
                viewModel.likeUser(user)
            } else {
                viewModel.skipUser(user)
            }
            offset = .zero // Reset pour la carte suivante
        }
    }
}
