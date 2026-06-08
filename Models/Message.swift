import Foundation

/// Représente un message (table: messages).
struct Message: Identifiable, Codable {
    var id: UUID?
    var senderId: UUID
    var text: String
    var timestamp: Date
}
