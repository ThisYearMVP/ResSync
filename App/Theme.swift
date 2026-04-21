import SwiftUI

extension Color {
    /// Bleu Majorelle ajusté (plus vibrant)
    static let majorelleBlue = Color(red: 45/255, green: 40/255, blue: 230/255)
}

/// Vue d'arrière-plan avec un hublot d'avion subtil
struct AirplaneWindowBackground: View {
    var body: some View {
        ZStack {
            // Fond dégradé ciel doux
            LinearGradient(colors: [Color.majorelleBlue.opacity(0.08), .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Forme du hublot subtile
            GeometryReader { geo in
                Capsule()
                    .stroke(Color.majorelleBlue.opacity(0.05), lineWidth: 60)
                    .frame(width: geo.size.width * 1.6, height: geo.size.height * 0.95)
                    .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.02)
                    .blur(radius: 30)
                
                Capsule()
                    .fill(
                        LinearGradient(colors: [Color.majorelleBlue.opacity(0.03), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: geo.size.width * 1.5, height: geo.size.height * 0.9)
                    .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.05)
                    .blur(radius: 10)
            }
        }
        .allowsHitTesting(false)
    }
}
