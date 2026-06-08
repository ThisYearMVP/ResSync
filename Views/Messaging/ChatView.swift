import SwiftUI
import ExyteChat

// Alias pour éviter le conflit avec le modèle Message de l'app
typealias AppMessage = Message

/// Interface de discussion — propulsée par ExyteChat.
struct ChatView: View {
    let matchedUser: User

    // Thème personnalisé aux couleurs ResSync
    private var chatTheme: ChatTheme {
        ChatTheme(
            colors: ChatTheme.Colors(
                mainBackground:      Color.clear,
                buttonBackground:    Color.majorelleBlue,
                addButtonForeground: Color.white,
                sendButtonForeground: Color.white,
                myMessage:           Color.majorelleBlue,
                friendMessage:       Color.white.opacity(0.14),
                inputLightBackground: Color.white.opacity(0.1),
                inputDarkBackground:  Color.white.opacity(0.08),
                inputText:           Color.white,
                inputPlaceholder:    Color.white.opacity(0.45),
                inputPlaceholderSelected: Color.white.opacity(0.3),
                myMessageText:       Color.white,
                friendMessageText:   Color.white,
                datePickerItemForeground: Color.white,
                statusRead:          Color.green,
                statusSent:          Color.white.opacity(0.7),
                statusSending:       Color.white.opacity(0.4)
            ),
            images: ChatTheme.Images(
                sendImage: Image(systemName: "paperplane.fill"),
                backButton: Image(systemName: "chevron.left"),
                scrollToBottom: Image(systemName: "chevron.down")
            )
        )
    }

    // Convertir les AppMessage du modèle vers ExyteChat.Message
    @State private var exMessages: [ExyteChat.Message] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Fond dégradé
            LinearGradient(
                colors: [Color.red.opacity(0.9), Color.majorelleDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                chatHeader

                if isLoading {
                    loadingBubbles
                } else {
                    ExyteChat.ChatView(messages: exMessages) { draft in
                        sendMessage(draft: draft)
                    }
                    .chatTheme(chatTheme)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationBarHidden(true)
        .task { await loadMessages() }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            BackButton()

            // Avatar
            avatarView(url: matchedUser.photoURLs.first)
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(matchedUser.name)
                    .font(.rsHeadline)
                    .foregroundColor(.white)
                if let trip = matchedUser.currentTrip {
                    Text("\(trip.origin) → \(trip.destination)")
                        .font(.rsCaption)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.white.opacity(0.12)))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.6))
    }

    // MARK: - Loading skeleton

    private var loadingBubbles: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(0..<5, id: \.self) { i in
                HStack {
                    if i % 2 == 0 { Spacer(minLength: 60) }
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.shimmerBase)
                        .frame(width: CGFloat.random(in: 120...220), height: 44)
                        .shimmering(
                            animation: .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                            gradient: Gradient(colors: [
                                Color.shimmerBase,
                                Color.shimmerHighlight,
                                Color.shimmerBase
                            ])
                        )
                    if i % 2 != 0 { Spacer(minLength: 60) }
                }
            }
            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    @ViewBuilder
    private func avatarView(url: String?) -> some View {
        if let urlStr = url, let photoURL = URL(string: urlStr) {
            AsyncImage(url: photoURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.majorelleBlue)
            }
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.glassStroke, lineWidth: 1))
        } else {
            Circle()
                .fill(Color.majorelleBlue)
                .overlay(
                    Text(String(matchedUser.name.prefix(1)))
                        .font(.rsHeadline)
                        .foregroundColor(.white)
                )
        }
    }

    private func loadMessages() async {
        try? await Task.sleep(nanoseconds: 600_000_000)
        withAnimation(.spring(response: 0.4)) {
            exMessages = sampleMessages()
            isLoading = false
        }
    }

    private func sendMessage(draft: DraftMessage) {
        let newMsg = ExyteChat.Message(
            id: UUID().uuidString,
            user: ExyteChat.User(
                id: "me",
                name: "Moi",
                avatarURL: nil,
                isCurrentUser: true
            ),
            status: .sending,
            createdAt: Date(),
            body: BodyType.text(draft.text)
        )
        withAnimation { exMessages.append(newMsg) }
    }

    private func sampleMessages() -> [ExyteChat.Message] {
        let other = ExyteChat.User(
            id: matchedUser.id?.uuidString ?? "other",
            name: matchedUser.name,
            avatarURL: matchedUser.photoURLs.first.flatMap { URL(string: $0) },
            isCurrentUser: false
        )
        let me = ExyteChat.User(id: "me", name: "Moi", avatarURL: nil, isCurrentUser: true)

        return [
            ExyteChat.Message(id: "1", user: other, status: .read,  createdAt: Date().addingTimeInterval(-300),
                              body: BodyType.text("Salut ! Tu vas à \(matchedUser.currentTrip?.destination ?? "destination") aussi ?")),
            ExyteChat.Message(id: "2", user: me,    status: .read,  createdAt: Date().addingTimeInterval(-240),
                              body: BodyType.text("Oui ! Pour le travail. Et toi ?")),
            ExyteChat.Message(id: "3", user: other, status: .read,  createdAt: Date().addingTimeInterval(-180),
                              body: BodyType.text("Pareil ! On se retrouve sur le quai ?")),
            ExyteChat.Message(id: "4", user: me,    status: .sent,  createdAt: Date().addingTimeInterval(-60),
                              body: BodyType.text("Top ! Je suis en voiture 4.")),
        ]
    }
}

// MARK: - Bouton retour réutilisable

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.white.opacity(0.12)))
        }
    }
}
