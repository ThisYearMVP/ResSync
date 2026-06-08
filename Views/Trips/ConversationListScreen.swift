import SwiftUI
import NukeUI

struct ConversationListScreen: View {
    let trip: Trip
    let mode: TravelMode
    @State private var conversations: [ConversationPreview] = ConversationPreview.mocks

    var body: some View {
        ZStack {
            if conversations.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(conversations) { conv in
                            NavigationLink(destination: ChatView(matchedUser: conv.toUser())) {
                                ConversationRow(conv: conv, mode: mode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 52)).foregroundColor(.white.opacity(0.22))
            Text("Aucune conversation")
                .font(.rsTitle).foregroundColor(.textSecondary)
            Text("Envoie une réaction à quelqu'un\npour démarrer une discussion.")
                .font(.rsBody).foregroundColor(.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

// MARK: - Ligne de conversation

struct ConversationRow: View {
    let conv: ConversationPreview
    let mode: TravelMode

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            LazyImage(url: conv.avatarURL) { state in
                if let image = state.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(Color.majorelleBlue)
                        .overlay(Text(String(conv.name.prefix(1))).font(.rsTitle).foregroundColor(.white))
                        .shimmering(active: state.isLoading)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(conv.isUnread ? mode.accentColor : Color.glassStroke, lineWidth: conv.isUnread ? 2 : 0.8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conv.name)
                        .font(.rsHeadline).foregroundColor(.white)
                    Spacer()
                    Text(conv.timeString)
                        .font(.rsCaption)
                        .foregroundColor(conv.isUnread ? mode.accentColor : .textSecondary)
                }
                Text(conv.lastMessage)
                    .font(.rsBody)
                    .foregroundColor(conv.isUnread ? .white : .textSecondary)
                    .lineLimit(1)
            }

            if conv.isUnread {
                Circle().fill(mode.accentColor).frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(.white.opacity(conv.isUnread ? 0.08 : 0.04))
        )
    }
}

// MARK: - Modèle prévisualisation conversation

struct ConversationPreview: Identifiable {
    let id = UUID()
    let name: String
    let avatarURL: URL?
    let lastMessage: String
    let timeString: String
    var isUnread: Bool

    func toUser() -> User {
        User(id: id, name: name, photoURLs: avatarURL.map { [$0.absoluteString] } ?? [])
    }

    static let mocks: [ConversationPreview] = [
        ConversationPreview(name: "Léa", avatarURL: URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200"),
                            lastMessage: "On se retrouve sur le quai ?", timeString: "14:32", isUnread: true),
        ConversationPreview(name: "Thomas", avatarURL: URL(string: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200"),
                            lastMessage: "Top ! Voiture 4, siège 22.", timeString: "12:08", isUnread: false),
    ]
}
