import SwiftUI
import NukeUI

struct ProfileDetailSheet: View {
    let participant: TripParticipant
    let mode: TravelMode
    let trip: Trip
    @Environment(\.dismiss) private var dismiss

    private var photos: [String] {
        mode == .love ? (participant.profileLove?.photos ?? []) : [participant.profileWork?.photo ?? ""].filter { !$0.isEmpty }
    }
    private var displayName: String {
        mode == .love ? (participant.profileLove?.name ?? "—") : (participant.profileWork?.name ?? "—")
    }
    private var bio: String {
        mode == .love ? (participant.profileLove?.bio ?? "") : (participant.profileWork?.bioPro ?? "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Fond
            LinearGradient(
                colors: [Color.red.opacity(0.9), Color.majorelleDark],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo grand format
                    photoHeader

                    // Contenu
                    VStack(alignment: .leading, spacing: 20) {
                        if mode == .love {
                            loveSections
                        } else {
                            workSections
                        }

                        messageButton
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }

            // Bouton fermeture
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.black.opacity(0.4)))
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }

    // MARK: - Photo

    private var photoHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let urlStr = photos.first, let url = URL(string: urlStr) {
                LazyImage(url: url) { state in
                    if let img = state.image { img.resizable().scaledToFill() }
                    else { Color.majorelleDark.shimmering(active: state.isLoading) }
                }
                .frame(height: 340).clipped()
            } else {
                ZStack {
                    Color.majorelleDark
                    Text(String(displayName.prefix(1)))
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(height: 340)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center, endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.rsDisplay).foregroundColor(.white)
                if mode == .love, let age = participant.profileLove?.age {
                    Text("\(age) ans • \(participant.profileLove?.nationality ?? "")")
                        .font(.rsBody).foregroundColor(.textSecondary)
                } else if mode == .work {
                    Text("\(participant.profileWork?.jobTitle ?? "") @ \(participant.profileWork?.company ?? "")")
                        .font(.rsBody).foregroundColor(.textSecondary)
                }
            }
            .padding(20)
        }
        .frame(height: 340)
    }

    // MARK: - Sections LOVE

    @ViewBuilder
    private var loveSections: some View {
        if !bio.isEmpty {
            sectionCard(title: "À propos") { Text(bio).font(.rsBody).foregroundColor(.textSecondary) }
        }
        if let interests = participant.profileLove?.interests, !interests.isEmpty {
            sectionCard(title: "Centres d'intérêt") {
                FlowLayout(items: interests) { interest in
                    Text(interest).pillTag()
                }
            }
        }
    }

    // MARK: - Sections WORK

    @ViewBuilder
    private var workSections: some View {
        if !bio.isEmpty {
            sectionCard(title: "Bio professionnelle") { Text(bio).font(.rsBody).foregroundColor(.textSecondary) }
        }
        if let skills = participant.profileWork?.skills, !skills.isEmpty {
            sectionCard(title: "Compétences") {
                FlowLayout(items: skills) { skill in
                    Text(skill).pillTag(color: Color.majorelleBlue.opacity(0.3))
                }
            }
        }
    }

    // MARK: - CTA message

    private var messageButton: some View {
        NavigationLink(destination: ChatView(matchedUser: participant.toUser(mode: mode))) {
            Label("Envoyer un message", systemImage: "message.fill")
                .font(.rsHeadline).foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: mode.gradientColors, startPoint: .leading, endPoint: .trailing))
                        .shadow(color: mode.accentColor.opacity(0.3), radius: 10, y: 4)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.rsCaption).foregroundColor(.textSecondary).textCase(.uppercase)
                .tracking(1)
            content()
        }
        .glassCard(cornerRadius: 16)
    }
}

// MARK: - TripParticipant → User

extension TripParticipant {
    func toUser(mode: TravelMode) -> User {
        switch mode {
        case .love:
            return User(
                id: userId,
                name: profileLove?.name ?? "—",
                age: profileLove?.age ?? 0,
                nationality: profileLove?.nationality ?? "",
                bio: profileLove?.bio ?? "",
                interests: profileLove?.interests ?? [],
                photoURLs: profileLove?.photos ?? []
            )
        case .work:
            return User(
                id: userId,
                name: profileWork?.name ?? "—",
                bio: profileWork?.bioPro ?? "",
                photoURLs: profileWork?.photo.isEmpty == false ? [profileWork!.photo] : []
            )
        }
    }
}

// MARK: - FlowLayout (chips multilignes)

struct FlowLayout<Item: Hashable, ItemView: View>: View {
    let items: [Item]
    let itemView: (Item) -> ItemView

    init(items: [Item], @ViewBuilder itemView: @escaping (Item) -> ItemView) {
        self.items = items
        self.itemView = itemView
    }

    var body: some View {
        var rows: [[Item]] = [[]]
        // Simple approximation — SwiftUI layout handles the rest via wrapping HStack
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in itemView(item) }
            }
        }
    }
}
