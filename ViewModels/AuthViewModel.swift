import Foundation
import Supabase
import Observation

/// Modèle pour la sélection du pays et de l'indicatif.
struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let flag: String
    let code: String
    let mask: String
    
    var digits: Int {
        mask.filter { $0 == "_" }.count
    }
}

/// ViewModel d'authentification consolidé avec gestion des étapes.
@Observable
class AuthViewModel {
    // Navigation
    var currentStep = 0
    
    // Étape 1: Identifiants
    var email = ""
    var phone = ""
    var password = ""
    var confirmPassword = ""
    var selectedCountry: Country = Country(name: "France", flag: "🇫🇷", code: "+33", mask: "_ __ __ __ __")
    
    // Étape 2: Identité
    var firstName = ""
    var lastName = ""
    var age = 18
    var nationality = ""
    
    // Étape 3: Intérêts et Préférences
    var selectedInterests: Set<String> = []
    var preferredVibe = "Calme"
    var travelHabit = "Musique"
    var bio = ""
    
    var errorMessage = ""
    var isLoading = false
    
    let allInterests = ["Voyage", "Sport", "Cuisine", "Tech", "Musique", "Cinéma", "Art", "Lecture", "Jeux Vidéo", "Photo", "Randonnée", "IA", "Mode", "Finance", "Histoire", "Nature"]
    let vibes = ["Calme", "Bavard", "Mixte"]
    let habits = ["Musique", "Lecture", "Travail", "Gaming", "Sommeil"]
    
    let countries = [
        Country(name: "France", flag: "🇫🇷", code: "+33", mask: "_ __ __ __ __"),
        Country(name: "Belgique", flag: "🇧🇪", code: "+32", mask: "_ ___ __ __"),
        Country(name: "Suisse", flag: "🇨🇭", code: "+41", mask: "__ ___ __ __"),
        Country(name: "Canada", flag: "🇨🇦", code: "+1", mask: "___ ___ ____")
    ]
    
    var fullPhoneNumber: String { "\(selectedCountry.code)\(phone)" }
    
    // Validations par étape
    var isStep1Valid: Bool {
        !email.isEmpty && password.count >= 6 && password == confirmPassword && phone.count == selectedCountry.digits
    }
    
    var isStep2Valid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !nationality.isEmpty && age >= 18
    }
    
    var isStep3Valid: Bool {
        selectedInterests.count >= 3 && selectedInterests.count <= 6
    }
    
    func nextStep() {
        if currentStep < 2 { currentStep += 1 }
    }
    
    func previousStep() {
        if currentStep > 0 { currentStep -= 1 }
    }
    
    /// Connexion utilisateur
    func signIn() async {
        isLoading = true
        errorMessage = ""
        do {
            try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = "Erreur de connexion : \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    /// Inscription utilisateur
    func signUp() async {
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await SupabaseService.shared.client.auth.signUp(email: email, password: password)
            let userId = response.user.id
            
            let fullBio = "Ambiance: \(preferredVibe). Activité favorite: \(travelHabit). \(bio)"
            
            let newUser = User(
                id: userId,
                name: "\(firstName) \(lastName)",
                phone: fullPhoneNumber,
                age: age,
                nationality: nationality,
                bio: fullBio,
                interests: Array(selectedInterests),
                photoURLs: []
            )
            
            try await SupabaseService.shared.saveUser(newUser)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < 6 {
            selectedInterests.insert(interest)
        }
    }
}
