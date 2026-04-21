import SwiftUI

extension Color {
    /// Bleu Majorelle ajusté (plus vibrant)
    static let majorelleBlue = Color(red: 45/255, green: 40/255, blue: 230/255)
}

/// Vue d'arrière-plan avec un hublot d'avion stylisé qui peut glisser
struct AirplaneWindowBackground: View {
    var selection: Int = 0
    
    var body: some View {
        ZStack {
            // Fond ciel bleu dégradé (statique ou léger mouvement)
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Nuages décoratifs qui bougent avec la sélection
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -50 - CGFloat(selection) * 50, y: 100)
                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.5 - CGFloat(selection) * 30, y: geo.size.height * 0.6)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selection)
            
            // Cadre du hublot qui glisse
            GeometryReader { geo in
                let totalTabs = 3
                // On calcule l'offset pour que le hublot soit à différentes positions
                // Sur l'onglet 0 (Profil) : très à droite
                // Sur l'onglet 1 (Mes Trajets) : centré
                // Sur l'onglet 2 (Ajouter) : très à gauche
                let horizontalOffset = geo.size.width * (0.4 - CGFloat(selection - 1) * 0.6)
                
                RoundedRectangle(cornerRadius: 140, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white, Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 40
                    )
                    .frame(width: geo.size.width * 1.8, height: geo.size.height * 1.2)
                    .offset(x: horizontalOffset, y: -geo.size.height * 0.1)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: -10, y: 10)
                
                // Reflet sur la vitre
                RoundedRectangle(cornerRadius: 140, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geo.size.width * 1.8, height: geo.size.height * 1.2)
                    .offset(x: horizontalOffset, y: -geo.size.height * 0.1)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selection)
        }
        .allowsHitTesting(false)
    }
}
