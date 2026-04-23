import Foundation
import Supabase
import PostgREST

/// Service pour interroger le cache des horaires TGV stocké sur Supabase.
class TgvService {
    private let client = SupabaseService.shared.client
    
    /// Recherche les horaires TGV enregistrés pour un trajet et une date.
    func searchTgvRoutes(origin: String, destination: String, date: Date) async throws -> [TgvSchedule] {
        // On calcule la fenêtre de temps pour la journée sélectionnée
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let schedules: [TgvSchedule] = try await client.from("tgv_schedules")
            .select()
            .ilike("origin", pattern: "%\(origin)%")
            .ilike("destination", pattern: "%\(destination)%")
            .gte("departure_time", value: startOfDay.iso8601String)
            .lt("departure_time", value: endOfDay.iso8601String)
            .order("departure_time", ascending: true)
            .execute()
            .value
            
        return schedules
    }
}

// Extension utilitaire pour le formatage des dates au format ISO8601 attendu par PostgREST
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
