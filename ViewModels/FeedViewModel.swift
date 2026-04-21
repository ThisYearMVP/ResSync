import Foundation
import Observation
import SwiftUI

@Observable
class FeedViewModel {
    var matchingUsers: [User] = []
    var isLoading = false
    
    private let matchingService = TripMatchingService()
    
    func loadMatches(for trip: Trip) async {
        isLoading = true
        do {
            let results = try await matchingService.fetchMatchingUsers(for: trip)
            if results.isEmpty {
                // Utilisation des mocks pour le développement si la base est vide
                matchingUsers = User.mocks
            } else {
                matchingUsers = results
            }
        } catch {
            print("Erreur de chargement : \(error.localizedDescription)")
            // Fallback sur les mocks en cas d'erreur réseau/base
            matchingUsers = User.mocks
        }
        isLoading = false
    }
    
    func likeUser(_ user: User) {
        // Enregistrez le match dans la base de données ici
        withAnimation {
            matchingUsers.removeAll { $0.id == user.id }
        }
    }
    
    func skipUser(_ user: User) {
        withAnimation {
            matchingUsers.removeAll { $0.id == user.id }
        }
    }
}
