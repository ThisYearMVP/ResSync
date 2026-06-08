import Foundation
import UIKit

// MARK: - Modèle de billet scanné

struct ScannedTicket {
    var transportType: TransportType
    var origin: String
    var destination: String
    var departureDate: Date
    var trainOrFlightNumber: String
    var seatNumber: String?
    var passengerName: String?
    var bookingReference: String?
    var confidence: Double  // 0.0 – 1.0
}

// MARK: - Erreurs

enum TicketScanError: LocalizedError {
    case imageEncodingFailed
    case apiError(String)
    case parsingFailed(String)
    case lowConfidence

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:   return "Impossible de lire l'image."
        case .apiError(let msg):     return "Erreur API : \(msg)"
        case .parsingFailed(let r):  return "Lecture du billet échouée : \(r)"
        case .lowConfidence:         return "Le billet n'est pas lisible. Essaie avec une photo plus nette."
        }
    }
}

// MARK: - Service

final class TicketScannerService {

    // À placer dans ton fichier de configuration ou dans les secrets de l'app
    private let apiKey = "VOTRE_CLE_ANTHROPIC"
    private let model  = "claude-sonnet-4-6"

    private let systemPrompt = """
    Tu es un expert en lecture de billets de transport (train SNCF, Eurostar, Thalys, TGV, OUIGO, avion).
    On te donne une photo d'un billet. Extrait les informations et réponds UNIQUEMENT avec un objet JSON valide, sans texte autour, sans markdown.
    Format attendu :
    {
      "transport_type": "train" | "plane",
      "origin": "nom complet de la gare ou aéroport de départ",
      "destination": "nom complet de la gare ou aéroport d'arrivée",
      "departure_datetime": "2025-06-15T14:32:00",
      "train_or_flight_number": "TGV 6231",
      "seat_number": "42B ou null si absent",
      "passenger_name": "NOM Prénom ou null si absent",
      "booking_reference": "code de réservation ou null si absent",
      "confidence": 0.95
    }
    Si une information est illisible, mets null. confidence = 1.0 si tout est clair, < 0.5 si le billet est très illisible.
    """

    func scan(image: UIImage) async throws -> ScannedTicket {
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw TicketScanError.imageEncodingFailed
        }
        let base64 = imageData.base64EncodedString()

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 512,
            "system": systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64
                            ]
                        ],
                        [
                            "type": "text",
                            "text": "Analyse ce billet et retourne le JSON."
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json",        forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,                    forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",              forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Réponse invalide"
            throw TicketScanError.apiError(msg)
        }

        return try parseResponse(data: data)
    }

    // MARK: - Parsing

    private func parseResponse(data: Data) throws -> ScannedTicket {
        guard
            let root    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = (root["content"] as? [[String: Any]])?.first,
            let text    = content["text"] as? String
        else {
            throw TicketScanError.parsingFailed("Structure API inattendue")
        }

        // Extraire le JSON brut (Claude peut parfois ajouter des espaces)
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let jsonData  = clean.data(using: .utf8),
            let ticket    = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            throw TicketScanError.parsingFailed(text)
        }

        let confidence = ticket["confidence"] as? Double ?? 0.0
        guard confidence >= 0.45 else { throw TicketScanError.lowConfidence }

        let transportRaw = ticket["transport_type"] as? String ?? "train"
        let transport: TransportType = transportRaw == "plane" ? .plane : .train

        let originRaw      = ticket["origin"]      as? String ?? ""
        let destinationRaw = ticket["destination"] as? String ?? ""
        let trainNumber    = ticket["train_or_flight_number"] as? String ?? ""

        guard !originRaw.isEmpty, !destinationRaw.isEmpty else {
            throw TicketScanError.parsingFailed("Départ ou destination introuvable")
        }

        let departureDate = parseDate(ticket["departure_datetime"] as? String)

        return ScannedTicket(
            transportType:       transport,
            origin:              originRaw,
            destination:         destinationRaw,
            departureDate:       departureDate,
            trainOrFlightNumber: trainNumber,
            seatNumber:          ticket["seat_number"]       as? String,
            passengerName:       ticket["passenger_name"]    as? String,
            bookingReference:    ticket["booking_reference"] as? String,
            confidence:          confidence
        )
    }

    private func parseDate(_ str: String?) -> Date {
        guard let str else { return Date() }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let d = formatter.date(from: str) { return d }
        // Fallback sans timezone
        let f2 = DateFormatter()
        f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f2.date(from: str) ?? Date()
    }
}
