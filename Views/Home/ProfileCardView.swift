import SwiftUI
import NukeUI
import Pow

/// Carte de profil style Tinder — NukeUI pour les photos, Pow pour les effets.
struct ProfileCardView: View {
    let user: User
    var swipeDirection: CGFloat = 0

    private var likeOpacity: Double  { max(0, min(1, Double(swipeDirection / 80)))  }
    private var nopeOpacity: Double  { max(0, min(1, Double(-swipeDirection / 80))) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                photoLayer(size: geo.size)
                overlayGradient
                swipeBadges
                infoOverlay
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .cardShadow, radius: 20, x: 0, y: 10)
        }
    }

    // MARK: - Photo

    @ViewBuilder
    private func photoLayer(size: CGSize) -> some View {
        if let urlStr = user.photoURLs.first, let url = URL(string: urlStr) {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipped()
                } else {
                    ZStack {
                        Color.majorelleDark
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(80)
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .frame(width: size.width, height: size.height)
                    .shimmering(active: state.isLoading)
                }
            }
        } else {
            ZStack {
                Color.majorelleDark
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(80)
                    .foregroundColor(.white.opacity(0.18))
            }
        }
    }

    // MARK: - Dégradé

    private var overlayGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .clear,                   location: 0.35),
                .init(color: .black.opacity(0.4),      location: 0.65),
                .init(color: .black.opacity(0.82),     location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Badges LIKE / NOPE (Pow fade)

    private var swipeBadges: some View {
        ZStack(alignment: .topLeading) {
            // LIKE
            Text("LIKE")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.green, lineWidth: 4)
                )
                .rotationEffect(.degrees(-15))
                .padding(.top, 48)
                .padding(.leading, 24)
                .opacity(likeOpacity)
                .animation(.interactiveSpring(), value: swipeDirection)

            // NOPE
            HStack {
                Spacer()
                Text("NOPE")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.red, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(15))
                    .padding(.top, 48)
                    .padding(.trailing, 24)
                    .opacity(nopeOpacity)
                    .animation(.interactiveSpring(), value: swipeDirection)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Informations

    private var infoOverlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Nom + âge
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(user.name)
                            .font(.rsDisplay)
                            .foregroundColor(.white)
                        Text("\(user.age)")
                            .font(.system(size: 26, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(user.nationality)
                    }
                    .font(.rsBody)
                    .foregroundColor(.textSecondary)
                }

                Spacer()

                // Badge activité
                if let trip = user.currentTrip {
                    VStack(spacing: 4) {
                        Image(systemName: trip.activity.icon)
                            .font(.title2)
                        Text(trip.activity.rawValue)
                            .font(.rsCaption)
                    }
                    .foregroundColor(.white)
                    .glassCard(cornerRadius: 14, padding: 12)
                }
            }

            // Bio
            Text(user.bio)
                .font(.rsBody)
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            // Intérêts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(user.interests, id: \.self) { interest in
                        Text(interest)
                            .pillTag()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .padding(.top, 12)
    }
}
