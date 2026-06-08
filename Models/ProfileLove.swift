import Foundation

struct ProfileLove: Identifiable, Codable, Equatable {
    var id: UUID?
    var userId: UUID?
    var name: String = ""
    var age: Int = 18
    var nationality: String = ""
    var bio: String = ""
    var interests: [String] = []
    var photos: [String] = []

    enum CodingKeys: String, CodingKey {
        case id
        case userId  = "user_id"
        case name, age, nationality, bio, interests, photos
    }
}
