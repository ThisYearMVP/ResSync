import SwiftUI
import NukeUI
import Pow
import AlertToast

struct PeopleScreen: View {
    let trip: Trip
    let mode: TravelMode

    @State private var vm = TripDetailViewModel()
    @State private var selectedParticipant: TripParticipant?
    @State private var toastMessage = ""
    @State private var showToast = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            if vm.isLoading {
                skeletonGrid
            } else if vm.participants.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.participants) { participant in
                            PersonCard(
                                participant: participant,
                                mode: mode,
                                onReaction: { reaction in
                                    Task { await sendReaction(reaction, to: participant) }
                                }
                            )
                            .onTapGesture { selectedParticipant = participant }
                            .transition(.movingParts.pop(Color.majorelleBlue.opacity(0.3)))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(item: $selectedParticipant) { participant in
            ProfileDetailSheet(participant: participant, mode: mode, trip: trip)
        }
        .toast(isPresenting: $showToast, duration: 2.5) {
            AlertToast(
                displayMode: .hud,
                type: .systemImage("hand.wave.fill", mode.accentColor),
                title: toastMessage,
                style: .style(backgroundColor: Color.majorelleDark, titleColor: .white, titleFont: .rsBody)
            )
        }
        .task { await vm.load(tripId: trip.id, mode: mode) }
    }

    // MARK: - Skeleton

    private var skeletonGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.shimmerBase)
                        .frame(height: 200)
                        .shimmering()
                }
            }
            .padding(.horizontal, 16).padding(.top, 8)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.3").font(.system(size: 56)).foregroundColor(.white.opacity(0.22))
            Text("Sois le premier !")
                .font(.rsTitle).foregroundColor(.textSecondary)
            Text("Personne n'a encore rejoint\nce trajet en mode \(mode.label).")
                .font(.rsBody).foregroundColor(.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Réaction

    private func sendReaction(_ reaction: ReactionType, to participant: TripParticipant) async {
        await vm.sendReaction(reaction, to: participant, tripId: trip.id)
        let name = mode == .love
            ? (participant.profileLove?.name ?? "cette personne")
            : (participant.profileWork?.name ?? "cette personne")
        toastMessage = "\(reaction.emoji) Envoyé à \(name) !"
        showToast = true
    }
}

// MARK: - Carte de personne

struct PersonCard: View {
    let participant: TripParticipant
    let mode: TravelMode
    let onReaction: (ReactionType) -> Void

    private var photoURL: URL? {
        let str = mode == .love
            ? participant.profileLove?.photos.first
            : participant.profileWork?.photo
        return str.flatMap { URL(string: $0) }
    }

    private var displayName: String {
        mode == .love
            ? (participant.profileLove?.name ?? "—")
            : (participant.profileWork?.name ?? "—")
    }

    private var subtitle: String {
        mode == .love
            ? "\(participant.profileLove?.age ?? 0) ans • \(participant.profileLove?.nationality ?? "")"
            : "\(participant.profileWork?.jobTitle ?? "") @ \(participant.profileWork?.company ?? "")"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Photo
            ZStack(alignment: .bottomLeading) {
                LazyImage(url: photoURL) { state in
                    if let image = state.image {
                        image.resizable().scaledToFill()
                    } else {
                        ZStack {
                            Color.majorelleDark
                            Text(String(displayName.prefix(1)))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .shimmering(active: state.isLoading)
                    }
                }
                .frame(height: 140)
                .clipped()

                // Dégradé bas
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .center, endPoint: .bottom
                )
            }
            .frame(height: 140)

            // Infos
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.rsHeadline).foregroundColor(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.rsCaption).foregroundColor(.textSecondary)
                    .lineLimit(1)

                // Réactions rapides
                HStack(spacing: 6) {
                    ForEach(ReactionType.allCases, id: \.self) { reaction in
                        Button(action: { onReaction(reaction) }) {
                            Text(reaction.emoji)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
            .padding(10)
            .background(Color.black.opacity(0.3))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.glassStroke, lineWidth: 0.8)
        )
        .shadow(color: .cardShadow, radius: 8, y: 4)
    }
}
