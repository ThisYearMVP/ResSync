import Foundation
import Observation

@Observable
class TripsViewModel {
    var trips: [Trip] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        do {
            trips = try await SupabaseService.shared.fetchUserTrips()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
