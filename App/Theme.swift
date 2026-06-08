import SwiftUI

// MARK: - Couleurs

extension Color {
    static let majorelleBlue  = Color(red: 45/255,  green: 40/255,  blue: 230/255)
    static let majorelleDark  = Color(red: 28/255,  green: 24/255,  blue: 160/255)
    static let glassWhite     = Color.white.opacity(0.12)
    static let glassStroke    = Color.white.opacity(0.25)
    static let textPrimary    = Color.white
    static let textSecondary  = Color.white.opacity(0.65)
    static let cardShadow     = Color.black.opacity(0.35)
    static let shimmerBase    = Color.white.opacity(0.08)
    static let shimmerHighlight = Color.white.opacity(0.22)
}

// MARK: - Typographie

extension Font {
    static let rsDisplay  = Font.system(size: 34, weight: .bold,   design: .rounded)
    static let rsTitle    = Font.system(size: 24, weight: .bold,   design: .rounded)
    static let rsHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let rsBody     = Font.system(size: 15, weight: .regular, design: .rounded)
    static let rsCaption  = Font.system(size: 12, weight: .medium,  design: .rounded)
}

// MARK: - Modificateurs réutilisables

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.glassStroke, lineWidth: 1)
                    )
            )
            .shadow(color: Color.cardShadow, radius: 16, x: 0, y: 8)
    }
}

struct PillTag: ViewModifier {
    var color: Color = .white.opacity(0.18)

    func body(content: Content) -> some View {
        content
            .font(.rsCaption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
    }
}

// MARK: - Shimmer (dépendance: markiv/Shimmer)
// Usage: .shimmering() — ajouté automatiquement par la lib

extension View {
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, padding: padding))
    }

    func pillTag(color: Color = .white.opacity(0.18)) -> some View {
        modifier(PillTag(color: color))
    }
}

// MARK: - Fond hublot (inchangé + amélioré)

struct AirplaneWindowBackground: View {
    var selection: Int

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()

            // Nuages flous
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.35))
                    .frame(width: 280, height: 280)
                    .blur(radius: 70)
                    .offset(x: -110 - CGFloat(selection) * 55, y: 160)

                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 380, height: 380)
                    .blur(radius: 80)
                    .offset(x: geo.size.width * 0.4 - CGFloat(selection) * 38,
                            y: geo.size.height * 0.68)

                // Halo bleu subtil
                Circle()
                    .fill(Color.majorelleBlue.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.6, y: 80)
            }

            // Cadre du hublot
            GeometryReader { geo in
                let w = geo.size.width * 0.95
                let h = geo.size.height * 0.75

                let targetX: CGFloat = {
                    switch selection {
                    case 0:  return geo.size.width * 1.5
                    case 1:  return geo.size.width
                    case 2:  return 0
                    default: return geo.size.width * 1.5
                    }
                }()

                ZStack {
                    RoundedRectangle(cornerRadius: 150, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white, Color.gray.opacity(0.4), .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 38
                        )
                        .shadow(color: .black.opacity(0.18), radius: 14, x: -4, y: 10)

                    RoundedRectangle(cornerRadius: 150, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.18), .clear, .white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: w, height: h)
                .position(x: targetX, y: geo.size.height * 0.48)
                .animation(.spring(response: 0.55, dampingFraction: 0.75), value: selection)
            }
        }
    }
}
