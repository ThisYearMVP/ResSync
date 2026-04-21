import SwiftUI

extension Color {
    /// Bleu Majorelle ajusté (plus vibrant)
    static let majorelleBlue = Color(red: 45/255, green: 40/255, blue: 230/255)
}

/// Vue d'arrière-plan avec un hublot d'avion stylisé qui glisse entre les pages
struct AirplaneWindowBackground: View {
    var selection: Int = 0
    
    var body: some View {
        ZStack {
            // Fond ciel bleu dégradé plus prononcé
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9), // Bleu plus profond en haut
                    Color(red: 0.6, green: 0.8, blue: 1.0)  // Bleu clair en bas
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Nuages qui bougent
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -100 - CGFloat(selection) * 60, y: 150)
                
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(x: geo.size.width * 0.4 - CGFloat(selection) * 40, y: geo.size.height * 0.7)
            }
            
            // Cadre du hublot qui glisse
            GeometryReader { geo in
                // selection 0 (Profil) -> Off-screen à droite
                // selection 1 (Mes Trajets) -> Aligné à droite (moitié gauche visible)
                // selection 2 (Ajouter) -> Aligné à gauche (moitié droite visible)
                
                let windowWidth = geo.size.width * 0.95
                let windowHeight = geo.size.height * 0.75
                
                let targetX: CGFloat = {
                    switch selection {
                    case 0: return geo.size.width * 1.5
                    case 1: return geo.size.width // Bord droit de l'écran = centre du hublot
                    case 2: return 0 // Bord gauche de l'écran = centre du hublot
                    default: return geo.size.width * 1.5
                    }
                }()
                
                ZStack {
                    // Ombre interne simulée
                    RoundedRectangle(cornerRadius: 150, style: .continuous)
                        .fill(Color.black.opacity(0.05))
                        .blur(radius: 10)
                    
                    // Cadre
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
                    
                    // Reflet
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
                .animation(.spring(response: 0.8, dampingFraction: 0.85), value: selection)
            }
        }
        .allowsHitTesting(false)
    }
}
