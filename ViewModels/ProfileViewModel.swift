import Foundation
import Observation

@Observable
class ProfileViewModel {
    var name = ""
    var age = 18
    var nationality = ""
    var bio = ""
    var interests: [String] = []
    
    init() {
        if let user = SupabaseService.shared.currentUser {
            self.name = user.name
            self.age = user.age
            self.nationality = user.nationality
            self.bio = user.bio
            self.interests = user.interests
        }
    }
    
    func saveProfile() async {
        guard var user = SupabaseService.shared.currentUser else { return }
        user.name = name
        user.age = age
        user.nationality = nationality
        user.bio = bio
        user.interests = interests
        
        try? await SupabaseService.shared.saveUser(user)
    }
}
