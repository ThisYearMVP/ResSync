import SwiftUI

enum TravelMode: String, Codable, CaseIterable {
    case love = "love"
    case work = "work"

    var label: String {
        switch self {
        case .love: return "LOVE"
        case .work: return "WORK"
        }
    }

    var emoji: String {
        switch self {
        case .love: return "💛"
        case .work: return "💼"
        }
    }

    var description: String {
        switch self {
        case .love: return "Rencontres et liens personnels"
        case .work: return "Networking et collaborations"
        }
    }

    var accentColor: Color {
        switch self {
        case .love: return Color(red: 1.0, green: 0.8, blue: 0.1)
        case .work: return Color(red: 0.2, green: 0.5, blue: 1.0)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .love: return [Color(red: 1.0, green: 0.45, blue: 0.3), Color(red: 1.0, green: 0.2, blue: 0.5)]
        case .work: return [Color(red: 0.15, green: 0.35, blue: 0.9), Color(red: 0.05, green: 0.15, blue: 0.55)]
        }
    }
}
