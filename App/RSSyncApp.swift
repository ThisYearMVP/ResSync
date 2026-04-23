import SwiftUI

@main
struct RSSyncApp: App {
    @State private var phase = 1
    
    init() {
        // Suppression radicale de TOUS les fonds système UIKit
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        UICollectionView.appearance().backgroundColor = .clear
        
        UIScrollView.appearance().backgroundColor = .clear
        
        UIPageControl.appearance().backgroundColor = .clear
        
        UITabBar.appearance().backgroundColor = .clear  
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        
        // Forcer la transparence des contrôleurs de navigation
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self]).backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // FOND ROUGE (Tout en bas)
                AirplaneWindowBackground(selection: phase)
                    .ignoresSafeArea()
                    .zIndex(0)

                ContentView(phase: $phase)
                    .zIndex(1)
            }
            .background(Color.clear)
        }
    }
}
