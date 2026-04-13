import Foundation
import Observation

/// ViewModel pour la recherche de trajets.
@Observable
class TripSearchViewModel {
    var origin = ""
    var destination = ""
    var date = Date()
    var transport: TransportType = .train
    var activity: ActivityType = .talk
    
    /// Soumet la recherche de trajet.
    /// - Returns: Le trajet configuré.
    func getTrip() -> Trip {
        return Trip(origin: origin, destination: destination, date: date, transport: transport, activity: activity)
    }
}
