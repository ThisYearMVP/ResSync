import Foundation

/// Représente l'utilisateur du réseau social de voyage (table: profiles).
struct User: Identifiable, Codable, Equatable {
    var id: UUID?
    var name: String
    var age: Int
    var nationality: String
    var bio: String
    var interests: [String]
    var photoURLs: [String]
    var currentTrip: Trip?

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
