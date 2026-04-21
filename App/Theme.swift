import SwiftUI

extension Color {
    static let majorelleBlue = Color(red: 45/255, green: 40/255, blue: 230/255)
}

/// Vue d'arrière-plan avec un hublot d'avion stylisé
struct AirplaneWindowBackground: View {
    var selection: Int
    
    var body: some View {
        ZStack {
            // Fond ciel bleu dégradé
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),
                    Color(red: 0.6, green: 0.8, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Nuages décoratifs
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -100 - CGFloat(selection) * 60, y: 150)
                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(x: geo.size.width * 0.4 - CGFloat(selection) * 40, y: geo.size.height * 0.7)
            }
            
            // Cadre du hublot
            GeometryReader { geo in
                let windowWidth = geo.size.width * 0.95
                let windowHeight = geo.size.height * 0.75
                
                // Positionnement horizontal basé sur la sélection
                // 0 (Profil) -> Hublot à droite
                // 1 (Mes Trajets) -> Hublot centré sur le bord droit (moitié gauche visible)
                // 2 (Ajouter) -> Hublot centré sur le bord gauche (moitié droite visible)
                let targetX: CGFloat = {
                    switch selection {
                    case 0: return geo.size.width * 1.5
                    case 1: return geo.size.width
                    case 2: return 0
                    default: return geo.size.width * 1.5
                    }
                }()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 150, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white, Color.gray.opacity(0.5), .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 40
                        )
                        .shadow(color: .black.opacity(0.2), radius: 15, x: -5, y: 10)
                    
                    RoundedRectangle(cornerRadius: 150, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: windowWidth, height: windowHeight)
                .position(x: targetX, y: geo.size.height * 0.48)
            }
        }
        .background(Color.clear)
    }
}
