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
            // Fond ciel bleu dégradé statique
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Nuages qui bougent légèrement
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -50 - CGFloat(selection) * 40, y: 100)
                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.5 - CGFloat(selection) * 20, y: geo.size.height * 0.6)
            }
            
            // Cadre du hublot qui glisse
            GeometryReader { geo in
                // Logique de glissement :
                // selection 0 (Profil) -> Complètement à droite (invisible)
                // selection 1 (Mes Trajets) -> Placé à l'extrême droite (on voit la moitié gauche)
                // selection 2 (Ajouter) -> Placé à l'extrême gauche (on voit la moitié droite)
                let width = geo.size.width * 0.9
                let height = geo.size.height * 0.7
                
                let targetX: CGFloat = {
                    switch selection {
                    case 0: return geo.size.width * 1.5
                    case 1: return geo.size.width // Centre du hublot sur le bord droit
                    case 2: return 0 // Centre du hublot sur le bord gauche
                    default: return geo.size.width * 1.5
                    }
                }()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 140, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white, Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 35
                        )
                        .shadow(color: .black.opacity(0.15), radius: 20, x: -10, y: 10)
                    
                    // Reflet sur la vitre
                    RoundedRectangle(cornerRadius: 140, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: width, height: height)
                .position(x: targetX, y: geo.size.height * 0.45)
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: selection)
            }
        }
        .allowsHitTesting(false)
    }
}
