import SwiftUI

@main
struct RSSyncApp: App {
    @State private var phase = 1
    
    init() {
        // Suppression radicale des fonds UIKit par défaut dès le démarrage
        UITableView.appearance().backgroundColor = .clear
        UITabBar.appearance().backgroundColor = .clear  
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
        
        // Forcer la transparence des contrôleurs de navigation
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // ARCHITECTURE RACINE : Le fond vit tout en haut, au-dessus de tout le système
                AirplaneWindowBackground(selection: phase)
                    .ignoresSafeArea()
                    .zIndex(0)

                ContentView(phase: $phase)
                    .background(Color.clear)
                    .zIndex(1)
            }
        }
    }
}
