import Foundation

/// Représente l'utilisateur du réseau social de voyage (table: profiles).
struct User: Identifiable, Codable, Equatable {
    var id: UUID?
    var name: String = ""
    var phone: String = ""
    var age: Int = 18
    var nationality: String = ""
    var bio: String = ""
    var interests: [String] = []
    var photoURLs: [String] = []
    var currentTrip: Trip?

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User {
    static let mocks: [User] = [
        User(
            id: UUID(),
            name: "Léa",
            age: 24,
            nationality: "Française 🇫🇷",
            bio: "Passionnée de rando et de tech. Je cherche quelqu'un pour discuter d'IA ou de voyage pendant le trajet !",
            interests: ["Tech", "Randonnée", "IA", "Photo"],
            photoURLs: ["https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop"],
            currentTrip: Trip(origin: "Paris", destination: "Lyon", date: Date(), transport: .train, activity: .talk)
        ),
        User(
            id: UUID(),
            name: "Marc",
            age: 31,
            nationality: "Suisse 🇨🇭",
            bio: "En déplacement pro. Je vais bosser tout le trajet, si tu veux co-worker en silence, welcome !",
            interests: ["Finance", "Running", "Lecture", "Café"],
            photoURLs: ["https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop"],
            currentTrip: Trip(origin: "Paris", destination: "Lyon", date: Date(), transport: .train, activity: .work)
        ),
        User(
            id: UUID(),
            name: "Sophie",
            age: 27,
            nationality: "Belge 🇧🇪",
            bio: "Grande fan de Switch ! Quelqu'un pour une partie de Mario Kart ou Smash ?",
            interests: ["Gaming", "Nintendo", "Anime", "Cosplay"],
            photoURLs: ["https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1000&auto=format&fit=crop"],
            currentTrip: Trip(origin: "Paris", destination: "Lyon", date: Date(), transport: .train, activity: .gaming)
        ),
        User(
            id: UUID(),
            name: "Thomas",
            age: 29,
            nationality: "Canadien 🇨🇦",
            bio: "Je rentre voir la famille. Très fatigué, je vais dormir tout le long, mais on peut se dire bonjour avant !",
            interests: ["Musique", "Sommeil", "Cinéma", "Poutine"],
            photoURLs: ["https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop"],
            currentTrip: Trip(origin: "Paris", destination: "Lyon", date: Date(), transport: .train, activity: .rest)
        ),
        User(
            id: UUID(),
            name: "Elena",
            age: 26,
            nationality: "Italienne 🇮🇹",
            bio: "Étudiante en art. Je voyage avec mon carnet de dessin. Curieuse de rencontrer du monde !",
            interests: ["Art", "Dessin", "Musées", "Pasta"],
            photoURLs: ["https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1000&auto=format&fit=crop"],
            currentTrip: Trip(origin: "Paris", destination: "Lyon", date: Date(), transport: .train, activity: .talk)
        )
    ]
}
