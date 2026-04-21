import Foundation
import Observation

@Observable
class TripSearchViewModel {
    var origin = ""
    var destination = ""
    var date = Date()
    var transport: TransportType = .train
    var activity: ActivityType = .talk
    
    // Cache local des horaires trouvés dans Supabase
    var availableRoutes: [TgvSchedule] = []
    var selectedRoute: TgvSchedule?
    var isLoadingRoutes = false
    
    // Suggestions de gares
    let allStations = [
        "Paris Gare de Lyon", "Paris Montparnasse", "Paris Nord", "Paris Est", "Lyon Part-Dieu",
        "Marseille Saint-Charles", "Bordeaux Saint-Jean", "Strasbourg", "Lille Europe",
        "Nantes", "Rennes", "Montpellier Saint-Roch", "Nice Ville", "Toulouse Matabiau"
    ]
    
    var filteredOrigins: [String] {
        origin.isEmpty ? [] : allStations.filter { $0.lowercased().contains(origin.lowercased()) && $0 != origin }
    }
    
    var filteredDestinations: [String] {
        destination.isEmpty ? [] : allStations.filter { $0.lowercased().contains(destination.lowercased()) && $0 != destination }
    }
    
    private let tgvService = TgvService()
    
    func searchRealRoutes() async {
        guard origin.count > 2 && destination.count > 2 else { return }
        
        isLoadingRoutes = true
        do {
            availableRoutes = try await tgvService.searchTgvRoutes(origin: origin, destination: destination, date: date)
        } catch {
            print("Erreur de recherche d'horaires : \(error)")
        }
        isLoadingRoutes = false
    }
    
    func getTrip() -> Trip {
        let finalDate = selectedRoute?.departure_time ?? date
        return Trip(origin: origin, destination: destination, date: finalDate, transport: transport, activity: activity)
    }
    
    /// Réinitialise le formulaire
    func reset() {
        origin = ""
        destination = ""
        date = Date()
        selectedRoute = nil
        availableRoutes = []
    }
}
