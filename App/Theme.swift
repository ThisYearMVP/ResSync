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

/// Animation d'avion qui "découvre" le menu avec profondeur et effets 3D
struct AirplaneRevealView: View {
    @State private var phase: Double = 0.0 // 0.0 -> 1.0
    @State private var opacity: Double = 1.0
    var onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fond blanc qui s'efface pour révéler le menu
                Color.white
                    .opacity(opacity)
                    .ignoresSafeArea()
                
                // Traînée de condensation (Contrail)
                Path { path in
                    path.move(to: CGPoint(x: -100, y: geo.size.height * 0.7))
                    path.addQuadCurve(
                        to: CGPoint(
                            x: -100 + (geo.size.width + 500) * phase,
                            y: geo.size.height * 0.7 - (geo.size.height * 0.5) * phase
                        ),
                        control: CGPoint(
                            x: geo.size.width * 0.3,
                            y: geo.size.height * 0.8
                        )
                    )
                }
                .trim(from: max(0, phase - 0.4), to: phase)
                .stroke(
                    LinearGradient(
                        colors: [.clear, .majorelleBlue.opacity(0.1), .white.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .blur(radius: 4)
                .opacity(opacity)
                
                // L'avion en 3D
                Image(systemName: "airplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(.majorelleBlue)
                    // Profondeur : grossit énormément en s'approchant
                    .scaleEffect(0.5 + phase * 3.5)
                    // Ombre dynamique qui s'éloigne (sensation de hauteur)
                    .shadow(
                        color: .black.opacity(0.3 - 0.2 * phase),
                        radius: 5 + 15 * phase,
                        x: -20 * phase,
                        y: 30 + 50 * phase
                    )
                    // Effets 3D : Tangage (Pitch) et Roulis (Roll)
                    .rotation3DEffect(
                        .degrees(35 - phase * 20),
                        axis: (x: 1, y: 0.5, z: 0),
                        perspective: 0.5
                    )
                    .rotationEffect(.degrees(-25 + phase * 10))
                    // Positionnement
                    .offset(
                        x: -150 + (geo.size.width + 500) * phase,
                        y: geo.size.height * 0.7 - (geo.size.height * 0.5) * phase
                    )
                    .opacity(opacity)
            }
        }
        .onAppear {
            // L'avion décolle et fonce vers l'utilisateur
            withAnimation(.timingCurve(0.3, 0.1, 0.2, 1, duration: 2.2)) {
                phase = 1.0
            }
            
            // Effacement progressif du rideau blanc
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 0
                }
            }
            
            // Finalisation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}
