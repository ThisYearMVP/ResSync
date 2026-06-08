import Foundation
import Observation

@Observable
class ProfileEditViewModel {
    // LOVE
    var loveName: String        = ""
    var loveAge: Int            = 18
    var loveNationality: String = ""
    var loveBio: String         = ""
    var loveInterests: [String] = []
    var lovePhotos: [String]    = []

    // WORK
    var workName: String     = ""
    var workJobTitle: String = ""
    var workCompany: String  = ""
    var workBioPro: String   = ""
    var workSkills: [String] = []
    var workPhoto: String    = ""

    var isSaving = false
    var errorMessage: String?
    var saveSuccess = false

    let interestOptions = [
        "Voyage", "Sport", "Cuisine", "Tech", "Musique", "Cinéma",
        "Art", "Lecture", "Jeux Vidéo", "Photo", "Randonnée", "IA",
        "Mode", "Finance", "Histoire", "Nature",
    ]

    let skillOptions = [
        "Swift", "Python", "Design", "Marketing", "Finance", "RH",
        "Vente", "Droit", "Médecine", "Architecture", "Data", "DevOps",
        "Product", "Consulting", "Management", "Communication",
    ]

    func load() async {
        guard let userId = try? await SupabaseService.shared.client.auth.session?.user.id else { return }
        async let loveTask = SupabaseService.shared.fetchProfileLove(userId: userId)
        async let workTask = SupabaseService.shared.fetchProfileWork(userId: userId)
        let (love, work) = (try? await loveTask, try? await workTask)
        if let l = love {
            loveName = l.name; loveAge = l.age; loveNationality = l.nationality
            loveBio = l.bio; loveInterests = l.interests; lovePhotos = l.photos
        }
        if let w = work {
            workName = w.name; workJobTitle = w.jobTitle; workCompany = w.company
            workBioPro = w.bioPro; workSkills = w.skills; workPhoto = w.photo
        }
    }

    func saveLove() async {
        guard let userId = try? await SupabaseService.shared.client.auth.session?.user.id else { return }
        isSaving = true
        let profile = ProfileLove(
            userId: userId,
            name: loveName, age: loveAge, nationality: loveNationality,
            bio: loveBio, interests: loveInterests, photos: lovePhotos
        )
        do {
            try await SupabaseService.shared.saveProfileLove(profile)
            saveSuccess = true
        } catch { errorMessage = error.localizedDescription }
        isSaving = false
    }

    func saveWork() async {
        guard let userId = try? await SupabaseService.shared.client.auth.session?.user.id else { return }
        isSaving = true
        let profile = ProfileWork(
            userId: userId,
            name: workName, jobTitle: workJobTitle, company: workCompany,
            bioPro: workBioPro, skills: workSkills, photo: workPhoto
        )
        do {
            try await SupabaseService.shared.saveProfileWork(profile)
            saveSuccess = true
        } catch { errorMessage = error.localizedDescription }
        isSaving = false
    }

    func toggleInterest(_ i: String) {
        if loveInterests.contains(i) { loveInterests.removeAll { $0 == i } }
        else if loveInterests.count < 6 { loveInterests.append(i) }
    }

    func toggleSkill(_ s: String) {
        if workSkills.contains(s) { workSkills.removeAll { $0 == s } }
        else if workSkills.count < 8 { workSkills.append(s) }
    }
}
