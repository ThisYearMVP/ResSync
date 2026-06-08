import Foundation
import Supabase
import PostgREST

/// Service de matching utilisant les requêtes Supabase.
class TripMatchingService {
    private let client = SupabaseService.shared.client
    
    /// Recherche les utilisateurs avec le même trajet.
    func fetchMatchingUsers(for trip: Trip) async throws -> [User] {
        // En Postgres, on utilise JSONB pour les colonnes imbriquées ou des colonnes séparées
        // On suppose ici que currentTrip est une colonne JSONB.
        let users: [User] = try await client.from("profiles")
            .select()
            .eq("currentTrip->>origin", value: trip.origin)
            .eq("currentTrip->>destination", value: trip.destination)
            .eq("currentTrip->>transport", value: trip.transport.rawValue)
            .execute()
            .value
            
        let currentUID = SupabaseService.shared.currentUser?.id
        return users.filter { $0.id != currentUID }
    }
}
