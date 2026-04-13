import Foundation
import Supabase
import Observation

/// Wrapper pour les interactions avec Supabase.
@Observable
class SupabaseService {
    static let shared = SupabaseService()
    
    // Remplacez par vos propres identifiants Supabase
    private let supabaseURL = URL(string: "https://zrtsionwgtgtcbnylvgs.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpydHNpb253Z3RndGNibnlsdmdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTQ3NDQsImV4cCI6MjA5MTY3MDc0NH0.e_Sc0ohZzkAhv9qLIPQJkK-wnvz9my6ktEp8OUGA8oM"
    
    let client: SupabaseClient
    
    var currentUser: User?
    var session: Session?
    
    var isAuthenticated: Bool { session != nil }
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        // Ecoute les changements de session
        Task {
            for await event in client.auth.authStateChanges {
                self.session = event.session
                if let user = event.session?.user {
                    await fetchCurrentUser(id: user.id)
                } else {
                    self.currentUser = nil
                }
            }
        }
    }
    
    /// Récupère le profil de l'utilisateur depuis la table 'profiles'.
    func fetchCurrentUser(id: UUID) async {
        do {
            let user: User = try await client.from("profiles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            self.currentUser = user
        } catch {
            print("Erreur fetch user: \(error)")
        }
    }
    
    /// Sauvegarde ou met à jour le profil.
    func saveUser(_ user: User) async throws {
        try await client.from("profiles")
            .upsert(user)
            .execute()
        self.currentUser = user
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
        self.currentUser = nil
    }
}
