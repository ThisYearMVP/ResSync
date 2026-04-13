import Foundation
import Observation

/// ViewModel d'authentification pour Supabase.
@Observable
class AuthViewModel {
    var email = ""
    var password = ""
    var errorMessage = ""
    var isLoading = false
    
    func signIn() async {
        isLoading = true
        errorMessage = ""
        do {
            try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signUp() async {
        isLoading = true
        errorMessage = ""
        do {
            try await SupabaseService.shared.client.auth.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
