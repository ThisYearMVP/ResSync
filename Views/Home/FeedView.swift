import SwiftUI
import Pow
import ConfettiSwiftUI
import AlertToast

struct FeedView: View {
    let searchTrip: Trip
    @State private var viewModel = FeedViewModel()
    @State private var offset: CGSize = .zero
    @Environment(\.dismiss) var dismiss

    // Confetti au moment du match
    @State private var confettiTrigger = 0
    // Toast de match
    @State private var showMatchToast = false
    @State private var matchedUserName = ""

    var body: some View {
        ZStack {
            // Fond
            LinearGradient(
                colors: [Color.red.opacity(0.88), Color.majorelleDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if viewModel.isLoading {
                    loadingStack
                } else if viewModel.matchingUsers.isEmpty {
                    emptyState
                } else {
                    cardStack
                    actionButtons
                }
            }

            // Confetti (ConfettiSwiftUI)
            ConfettiCannon(
                trigger: .onTarget(confettiTrigger, target: confettiTrigger + 1),
                num: 80,
                confettis: [.shape(.circle), .shape(.triangle), .shape(.square)],
                colors: [.majorelleBlue, .white, .red, .yellow],
                openingAngle: Angle(degrees: 60),
                closingAngle: Angle(degrees: 120),
                radius: 350
            )
        }
        .navigationBarHidden(true)
        // Toast (AlertToast)
        .toast(isPresenting: $showMatchToast, duration: 3.5, tapToDismiss: true) {
            AlertToast(
                displayMode: .hud,
                type: .systemImage("heart.fill", .pink),
                title: "C'est un match !",
                subTitle: "Tu as matché avec \(matchedUserName) 🎉",
                style: .style(
                    backgroundColor:   Color.majorelleDark,
                    titleColor:        .white,
                    subTitleColor:     .textSecondary,
                    titleFont:         .rsHeadline,
                    subTitleFont:      .rsBody
                )
            )
        }
        .task { await viewModel.loadMatches(for: searchTrip) }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(.white.opacity(0.12)))
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(searchTrip.origin) → \(searchTrip.destination)")
                    .font(.rsHeadline)
                    .foregroundColor(.white)
                Text("\(searchTrip.transport.rawValue) • \(searchTrip.activity.rawValue)")
                    .font(.rsCaption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Circle().fill(.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Stack de cartes

    private var cardStack: some View {
        ZStack {
            ForEach(viewModel.matchingUsers.reversed()) { user in
                let isTop = user == viewModel.matchingUsers.first

                ProfileCardView(
                    user: user,
                    swipeDirection: isTop ? offset.width : 0
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // Décalage et rotation pour l'effet de pile
                .offset(y: stackOffset(for: user))
                .scaleEffect(stackScale(for: user))
                // Seulement la carte du dessus est interactive
                .offset(x: isTop ? offset.width : 0,
                        y: isTop ? offset.height * 0.25 : 0)
                .rotationEffect(.degrees(isTop ? Double(offset.width / 18) : 0))
                .gesture(
                    DragGesture()
                        .onChanged { g in guard isTop else { return }; offset = g.translation }
                        .onEnded   { g in guard isTop else { return }; handleSwipe(g.translation.width, user: user) }
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.72), value: offset)
                // Pow : entrée de chaque carte avec un effet swoosh
                .transition(
                    .asymmetric(
                        insertion: .movingParts.swoosh,
                        removal:   .movingParts.fly
                    )
                )
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Boutons d'action

    private var actionButtons: some View {
        HStack(spacing: 44) {
            // Passer
            Button(action: { swipeAction(direction: -600, user: viewModel.matchingUsers.first) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(.white))
                    .shadow(color: .red.opacity(0.3), radius: 10, y: 5)
            }
            // Pow : effet de rebond au tap
            .changeEffect(.spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                Image(systemName: "xmark").foregroundColor(.red)
            }, value: viewModel.matchingUsers.count)

            // Liker
            Button(action: { swipeAction(direction: 600, user: viewModel.matchingUsers.first, isLike: true) }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.green)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(.white))
                    .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
            }
            // Pow : coeurs qui partent vers le haut au like
            .changeEffect(.spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                Image(systemName: "heart.fill").foregroundColor(.pink)
            }, value: viewModel.matchingUsers.count)
        }
        .padding(.bottom, 44)
    }

    // MARK: - Loading

    private var loadingStack: some View {
        VStack {
            Spacer()
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.shimmerBase)
                        .frame(height: UIScreen.main.bounds.height * 0.58)
                        .padding(.horizontal, CGFloat(i * 8 + 16))
                        .offset(y: CGFloat(i * -10))
                        .shimmering()
                }
            }
            Spacer()
            HStack(spacing: 44) {
                ForEach(0..<2, id: \.self) { _ in
                    Circle()
                        .fill(Color.shimmerBase)
                        .frame(width: 64, height: 64)
                        .shimmering()
                }
            }
            .padding(.bottom, 44)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.3.sequence")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.25))
            Text("Plus de voyageurs")
                .font(.rsTitle)
                .foregroundColor(.textSecondary)
            Text("Revenez plus tard, de nouveaux profils arrivent !")
                .font(.rsBody)
                .foregroundColor(.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Logique de swipe

    private func stackOffset(for user: User) -> CGFloat {
        guard let idx = viewModel.matchingUsers.firstIndex(of: user) else { return 0 }
        return CGFloat(idx) * -12
    }

    private func stackScale(for user: User) -> CGFloat {
        guard let idx = viewModel.matchingUsers.firstIndex(of: user) else { return 1 }
        return max(0.88, 1 - CGFloat(idx) * 0.04)
    }

    private func handleSwipe(_ width: CGFloat, user: User) {
        if width > 130 {
            swipeAction(direction: 600, user: user, isLike: true)
        } else if width < -130 {
            swipeAction(direction: -600, user: user)
        } else {
            withAnimation(.spring()) { offset = .zero }
        }
    }

    private func swipeAction(direction: CGFloat, user: User?, isLike: Bool = false) {
        guard let user else { return }
        withAnimation(.spring(response: 0.35)) { offset.width = direction }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            if isLike {
                viewModel.likeUser(user)
                // Simuler un match (à remplacer par la logique réelle)
                let didMatch = Bool.random()
                if didMatch {
                    matchedUserName = user.name
                    confettiTrigger += 1
                    showMatchToast = true
                }
            } else {
                viewModel.skipUser(user)
            }
            withAnimation(.spring()) { offset = .zero }
        }
    }
}
