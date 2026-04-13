import Foundation
import Observation

/// ViewModel pour le flux de profils (Feed).
@Observable
class FeedViewModel {
    var matchingUsers: [User] = []
    var isLoading = false
    
    private let matchingService = TripMatchingService()
    
    /// Charge les utilisateurs qui matchent avec le trajet donné.
    func loadMatches(for trip: Trip) async {
        isLoading = true
        do {
            matchingUsers = try await matchingService.fetchMatchingUsers(for: trip)
        } catch {
            print("Erreur de chargement : \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    /// Action lors d'un swipe à droite (intéressé).
    func likeUser(_ user: User) {
        // Logique de création de match Firestore à implémenter ici.
        matchingUsers.removeAll { $0.id == user.id }
    }
    
    /// Action lors d'un swipe à gauche (passer).
    func skipUser(_ user: User) {
        matchingUsers.removeAll { $0.id == user.id }
    }
}
