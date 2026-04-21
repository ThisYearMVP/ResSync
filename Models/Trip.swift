import Foundation

/// Définit un trajet avec son origine, sa destination et l'activité souhaitée durant le voyage.
struct Trip: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var origin: String
    var destination: String
    var date: Date
    var transport: TransportType
    var activity: ActivityType
}

/// Types de transports supportés.
enum TransportType: String, Codable, CaseIterable {
    case train = "Train"
    case plane = "Avion"
    
    var icon: String {
        switch self {
        case .train: return "train.side.front.car"
        case .plane: return "airplane"
        }
    }
}

/// Représente un trajet réel issu du cache (SNCF API)
struct TgvSchedule: Identifiable, Codable, Hashable {
    var id: UUID?
    var train_number: String
    var origin: String
    var destination: String
    var departure_time: Date
    var transport_type: String
}

/// Activités que les voyageurs souhaitent partager.
enum ActivityType: String, Codable, CaseIterable {
    case work = "Travailler"
    case talk = "Parler"
    case rest = "Se reposer"
    case gaming = "Jouer"
    case other = "Autre"
    
    var icon: String {
        switch self {
        case .work: return "laptopcomputer"
        case .talk: return "bubble.left.and.bubble.right"
        case .rest: return "zzz"
        case .gaming: return "gamecontroller"
        case .other: return "ellipsis.circle"
        }
    }
}
