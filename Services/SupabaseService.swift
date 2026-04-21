import Foundation
import Supabase
import PostgREST
import Observation

/// Wrapper pour les interactions avec Supabase.
@Observable
class SupabaseService {
    static let shared = SupabaseService()
    
    // Remplacez par vos propres identifiants Supabase
    private let supabaseURL = URL(string: "https://zrtsionwgtgtcbnylvgs.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpydHNpb253Z3RndGNibnlsdmdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTQ3NDQsImV4cCI6MjA5MTY3MDc0NH0.e_Sc0ohZzkAhv9qLIPQJkK-wnvz9my6ktEp8OUGA8oM"
    
    let client: SupabaseClient
    
    var currentUser: User?
    var session: Session?
    
    var isAuthenticated: Bool { session != nil }
    
    var isProfileComplete: Bool {
        guard let user = currentUser else { return false }
        return !user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && user.interests.count >= 3
    }
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        // Ecoute les changements de session
        Task {
            for await event in client.auth.authStateChanges {
                self.session = event.session
                if let user = event.session?.user {
                    // Si le profil n'est pas encore en mémoire, on l'initialise
                    if self.currentUser == nil {
                        self.currentUser = User(id: user.id)
                    }
                    await fetchCurrentUser(id: user.id)
                } else {
                    self.currentUser = nil
                }
            }
        }
    }
    
    /// Récupère le profil de l'utilisateur depuis la table 'profiles'.
    func fetchCurrentUser(id: UUID) async {
        do {
            let user: User = try await client.from("profiles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            self.currentUser = user
        } catch {
            print("Erreur fetch user: \(error)")
        }
    }
    
    /// Sauvegarde ou met à jour le profil.
    func saveUser(_ user: User) async throws {
        try await client.from("profiles")
            .upsert(user)
            .execute()
        self.currentUser = user
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
        self.currentUser = nil
    }
    
    /// Enregistre un nouveau trajet pour l'utilisateur
    func saveUserTrip(_ trip: Trip) async throws {
        guard let userId = session?.user.id else { return }
        
        let data: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString.lowercased()),
            "origin": .string(trip.origin),
            "destination": .string(trip.destination),
            "departure_time": .string(trip.date.iso8601String),
            "transport_type": .string(trip.transport.rawValue),
            "activity_type": .string(trip.activity.rawValue)
        ]
        
        try await client.from("user_trips").insert(data).execute()
    }
    
    /// Récupère tous les trajets de l'utilisateur
    func fetchUserTrips() async throws -> [Trip] {
        guard let userId = session?.user.id else { return [] }
        
        let response: [TripDTO] = try await client.from("user_trips")
            .select()
            .eq("user_id", value: userId)
            .order("departure_time", ascending: true)
            .execute()
            .value
            
        return response.map { $0.toTrip() }
    }
}

/// Objet de transfert de données pour les trajets
struct TripDTO: Codable {
    let id: UUID
    let origin: String
    let destination: String
    let departure_time: Date
    let transport_type: String
    let activity_type: String
    
    func toTrip() -> Trip {
        Trip(
            id: id.uuidString,
            origin: origin,
            destination: destination,
            date: departure_time,
            transport: TransportType(rawValue: transport_type) ?? .train,
            activity: ActivityType(rawValue: activity_type) ?? .talk
        )
    }
}

