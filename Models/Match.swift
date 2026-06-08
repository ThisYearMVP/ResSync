import Foundation

/// Représente un match (table: matches).
struct Match: Identifiable, Codable {
    var id: UUID?
    var user1Id: UUID
    var user2Id: UUID
    var timestamp: Date
}
