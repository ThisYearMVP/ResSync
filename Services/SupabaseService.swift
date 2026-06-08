import Foundation
import Supabase
import PostgREST
import Observation

@Observable
class SupabaseService {
    static let shared = SupabaseService()

    private let supabaseURL = URL(string: "https://zrtsionwgtgtcbnylvgs.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpydHNpb253Z3RndGNibnlsdmdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTQ3NDQsImV4cCI6MjA5MTY3MDc0NH0.e_Sc0ohZzkAhv9qLIPQJkK-wnvz9my6ktEp8OUGA8oM"

    let client: SupabaseClient

    var currentUser: User?
    var session: Session?
    var isInitialLoadComplete = false

    var isAuthenticated: Bool { session != nil }

    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        Task {
            if let s = try? await client.auth.session {
                self.session = s
                await fetchCurrentUser(id: s.user.id)
            }
            await MainActor.run { self.isInitialLoadComplete = true }
            for await event in client.auth.authStateChanges {
                self.session = event.session
                if let u = event.session?.user {
                    if self.currentUser == nil { self.currentUser = User(id: u.id) }
                    await fetchCurrentUser(id: u.id)
                } else {
                    self.currentUser = nil
                }
            }
        }
    }

    // MARK: - Auth

    func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
        self.currentUser = nil
    }

    // MARK: - Profil utilisateur de base

    func fetchCurrentUser(id: UUID) async {
        do {
            let user: User = try await client.from("profiles")
                .select().eq("id", value: id).single().execute().value
            self.currentUser = user
        } catch { print("fetchCurrentUser: \(error)") }
    }

    func saveUser(_ user: User) async throws {
        try await client.from("profiles").upsert(user).execute()
        self.currentUser = user
    }

    // MARK: - Profil LOVE

    func fetchProfileLove(userId: UUID) async throws -> ProfileLove? {
        let results: [ProfileLove] = try await client.from("profiles_love")
            .select().eq("user_id", value: userId).execute().value
        return results.first
    }

    func saveProfileLove(_ profile: ProfileLove) async throws {
        try await client.from("profiles_love").upsert(profile).execute()
    }

    // MARK: - Profil WORK

    func fetchProfileWork(userId: UUID) async throws -> ProfileWork? {
        let results: [ProfileWork] = try await client.from("profiles_work")
            .select().eq("user_id", value: userId).execute().value
        return results.first
    }

    func saveProfileWork(_ profile: ProfileWork) async throws {
        try await client.from("profiles_work").upsert(profile).execute()
    }

    // MARK: - Trajets

    func saveUserTrip(_ trip: Trip) async throws {
        let s = try? await client.auth.session
        guard let userId = s?.user.id else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Non connecté"])
        }
        let data: [String: AnyJSON] = [
            "user_id":        .string(userId.uuidString),
            "origin":         .string(trip.origin),
            "destination":    .string(trip.destination),
            "departure_time": .string(trip.date.iso8601String),
            "transport_type": .string(trip.transport.rawValue),
            "activity_type":  .string(trip.activity.rawValue),
        ]
        try await client.from("user_trips").insert(data).execute()
    }

    func fetchUserTrips() async throws -> [Trip] {
        let s = try? await client.auth.session
        guard let userId = s?.user.id else { return [] }
        let dtos: [TripDTO] = try await client.from("user_trips")
            .select().eq("user_id", value: userId)
            .order("departure_time", ascending: true).execute().value
        return dtos.map { $0.toTrip() }
    }

    // MARK: - Participants d'un trajet

    func joinTrip(tripId: String, mode: TravelMode) async throws {
        let s = try? await client.auth.session
        guard let userId = s?.user.id else { return }
        let data: [String: AnyJSON] = [
            "trip_id": .string(tripId),
            "user_id": .string(userId.uuidString),
            "mode":    .string(mode.rawValue),
        ]
        try await client.from("trip_participants").upsert(data).execute()
    }

    func fetchParticipants(tripId: String, mode: TravelMode) async throws -> [TripParticipant] {
        let participants: [TripParticipant] = try await client.from("trip_participants")
            .select()
            .eq("trip_id", value: tripId)
            .eq("mode", value: mode.rawValue)
            .execute().value
        return participants
    }

    func fetchProfilesLove(userIds: [UUID]) async throws -> [ProfileLove] {
        guard !userIds.isEmpty else { return [] }
        let ids = userIds.map { $0.uuidString }
        let profiles: [ProfileLove] = try await client.from("profiles_love")
            .select().in("user_id", values: ids).execute().value
        return profiles
    }

    func fetchProfilesWork(userIds: [UUID]) async throws -> [ProfileWork] {
        guard !userIds.isEmpty else { return [] }
        let ids = userIds.map { $0.uuidString }
        let profiles: [ProfileWork] = try await client.from("profiles_work")
            .select().in("user_id", values: ids).execute().value
        return profiles
    }

    // MARK: - Réactions

    func sendReaction(tripId: String, toUserId: UUID, reaction: ReactionType) async throws {
        let s = try? await client.auth.session
        guard let fromUserId = s?.user.id else { return }
        let data: [String: AnyJSON] = [
            "trip_id":      .string(tripId),
            "from_user_id": .string(fromUserId.uuidString),
            "to_user_id":   .string(toUserId.uuidString),
            "reaction":     .string(reaction.rawValue),
        ]
        try await client.from("profile_reactions").insert(data).execute()
    }
}

// MARK: - TripDTO

struct TripDTO: Codable {
    let id: UUID
    let origin: String
    let destination: String
    let departure_time: String
    let transport_type: String
    let activity_type: String

    func toTrip() -> Trip {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        let date = f1.date(from: departure_time) ?? f2.date(from: departure_time) ?? Date()
        return Trip(
            id: id.uuidString, origin: origin, destination: destination,
            date: date,
            transport: TransportType(rawValue: transport_type) ?? .train,
            activity: ActivityType(rawValue: activity_type) ?? .talk
        )
    }
}
