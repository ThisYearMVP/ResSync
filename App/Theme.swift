import SwiftUI

extension Color {
    /// Bleu Majorelle ajusté (plus vibrant)
    static let majorelleBlue = Color(red: 45/255, green: 40/255, blue: 230/255)
}

/// Vue d'arrière-plan avec un hublot d'avion stylisé
struct AirplaneWindowBackground: View {
    var body: some View {
        ZStack {
            // Fond ciel bleu dégradé
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Nuages décoratifs
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -50, y: 100)
                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.6)
            }
            
            // Cadre du hublot
            GeometryReader { geo in
                let width = geo.size.width * 0.85
                let height = geo.size.height * 0.7
                
                RoundedRectangle(cornerRadius: 140, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white, Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 35
                    )
                    .frame(width: width, height: height)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.45)
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
                    .frame(width: width, height: height)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.45)
            }
        }
        .allowsHitTesting(false)
    }
}
