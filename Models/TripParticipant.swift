import Foundation

struct TripParticipant: Identifiable, Codable {
    var id: UUID?
    var tripId: String
    var userId: UUID
    var mode: TravelMode
    var joinedAt: Date?

    // Données dénormalisées pour l'affichage (non stockées en DB)
    var profileLove: ProfileLove?
    var profileWork: ProfileWork?

    enum CodingKeys: String, CodingKey {
        case id
        case tripId    = "trip_id"
        case userId    = "user_id"
        case mode
        case joinedAt  = "joined_at"
    }
}

struct ProfileReaction: Identifiable, Codable {
    var id: UUID?
    var tripId: String
    var fromUserId: UUID
    var toUserId: UUID
    var reaction: ReactionType
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case tripId      = "trip_id"
        case fromUserId  = "from_user_id"
        case toUserId    = "to_user_id"
        case reaction
        case createdAt   = "created_at"
    }
}

enum ReactionType: String, Codable, CaseIterable {
    case wave   = "wave"
    case coffee = "coffee"
    case chat   = "chat"

    var emoji: String {
        switch self {
        case .wave:   return "👋"
        case .coffee: return "☕"
        case .chat:   return "💬"
        }
    }

    var label: String {
        switch self {
        case .wave:   return "Bonjour"
        case .coffee: return "Café ?"
        case .chat:   return "Discuter"
        }
    }
}
