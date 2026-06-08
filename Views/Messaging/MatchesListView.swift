import SwiftUI
import NukeUI
import Pow

/// Liste des matchs — NukeUI pour les avatars, Pow pour les transitions de lignes.
struct MatchesListView: View {
    @State private var matches: [MatchPreview] = MatchPreview.mocks
    @State private var isLoading = true
    @State private var searchText = ""

    private var filtered: [MatchPreview] {
        guard !searchText.isEmpty else { return matches }
        return matches.filter {
            $0.userName.localizedCaseInsensitiveContains(searchText) ||
            $0.lastMessage.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.85), Color.majorelleDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchBar
                content
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            withAnimation(.spring(response: 0.45)) { isLoading = false }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Messages")
                .font(.rsDisplay)
                .foregroundColor(.white)
            Spacer()
            Button(action: {}) {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(.white.opacity(0.12)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Barre de recherche

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("Rechercher...", text: $searchText)
                .foregroundColor(.white)
                .tint(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.glassStroke, lineWidth: 0.8)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Contenu

    @ViewBuilder
    private var content: some View {
        if isLoading {
            skeletonList
        } else if filtered.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filtered) { match in
                        NavigationLink(destination: ChatView(matchedUser: match.toUser())) {
                            MatchRow(match: match)
                        }
                        .buttonStyle(.plain)
                        // Pow : entrée glissée + fade par index
                        .transition(
                            .asymmetric(
                                insertion: .movingParts.slide.combined(with: .opacity),
                                removal:   .movingParts.vanish
                            )
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Skeleton

    private var skeletonList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color.shimmerBase)
                            .frame(width: 56, height: 56)
                            .shimmering()

                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.shimmerBase)
                                .frame(width: 120, height: 14)
                                .shimmering()
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.shimmerBase)
                                .frame(width: 200, height: 12)
                                .shimmering()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            Text("Aucun message")
                .font(.rsTitle)
                .foregroundColor(.textSecondary)
            Text("Swipe des profils pour commencer à matcher !")
                .font(.rsBody)
                .foregroundColor(.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(32)
    }
}

// MARK: - Ligne de match

struct MatchRow: View {
    let match: MatchPreview

    var body: some View {
        HStack(spacing: 14) {
            // Avatar NukeUI
            LazyImage(url: match.avatarURL) { state in
                if let image = state.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle()
                        .fill(Color.majorelleBlue)
                        .overlay(
                            Text(String(match.userName.prefix(1)))
                                .font(.rsTitle)
                                .foregroundColor(.white)
                        )
                        .shimmering(active: state.isLoading)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(
                Circle().strokeBorder(
                    match.isUnread ? Color.majorelleBlue : Color.glassStroke,
                    lineWidth: match.isUnread ? 2.5 : 1
                )
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(match.userName)
                        .font(.rsHeadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(match.timeString)
                        .font(.rsCaption)
                        .foregroundColor(match.isUnread ? Color.majorelleBlue : .textSecondary)
                }

                HStack(spacing: 6) {
                    Text(match.tripLabel)
                        .pillTag(color: Color.majorelleBlue.opacity(0.3))

                    Text(match.lastMessage)
                        .font(.rsBody)
                        .foregroundColor(match.isUnread ? .white : .textSecondary)
                        .lineLimit(1)
                }
            }

            if match.isUnread {
                Circle()
                    .fill(Color.majorelleBlue)
                    .frame(width: 10, height: 10)
                    // Pow : pulsation tant que non lu
                    .conditionalEffect(
                        .repeat(.pulse(by: 0.25), every: 1.5),
                        condition: match.isUnread
                    )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(match.isUnread ? 0.1 : 0.05))
        )
    }
}

// MARK: - Modèle de prévisualisation

struct MatchPreview: Identifiable {
    let id = UUID()
    let userName: String
    let avatarURL: URL?
    let lastMessage: String
    let tripLabel: String
    let timeString: String
    var isUnread: Bool

    func toUser() -> User {
        User(id: id, name: userName, photoURLs: avatarURL.map { [$0.absoluteString] } ?? [])
    }

    static let mocks: [MatchPreview] = [
        MatchPreview(userName: "Léa", avatarURL: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200"),
                     lastMessage: "On se retrouve sur le quai ?", tripLabel: "Paris → Lyon", timeString: "14:32", isUnread: true),
        MatchPreview(userName: "Thomas", avatarURL: URL(string: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200"),
                     lastMessage: "Top ! Je suis en voiture 4.", tripLabel: "Paris → Lyon", timeString: "12:08", isUnread: false),
        MatchPreview(userName: "Sophie", avatarURL: URL(string: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200"),
                     lastMessage: "Tu joues à quoi ?", tripLabel: "Paris → Bordeaux", timeString: "Hier", isUnread: true),
        MatchPreview(userName: "Marc", avatarURL: URL(string: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200"),
                     lastMessage: "À tout à l'heure !", tripLabel: "Paris → Marseille", timeString: "Lun", isUnread: false),
    ]
}
