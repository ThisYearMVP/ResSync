import Foundation

struct ProfileWork: Identifiable, Codable, Equatable {
    var id: UUID?
    var userId: UUID?
    var name: String = ""
    var jobTitle: String = ""
    var company: String = ""
    var bioPro: String = ""
    var skills: [String] = []
    var photo: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case userId   = "user_id"
        case name
        case jobTitle = "job_title"
        case company
        case bioPro   = "bio_pro"
        case skills, photo
    }
}
