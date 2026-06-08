import type { TransportType } from "./types";

// ⚠️ Mets ta vraie clé Anthropic ici (ou via process.env / app config).
const ANTHROPIC_API_KEY = "VOTRE_CLE_ANTHROPIC";
const MODEL = "claude-sonnet-4-6";

export interface ScannedTicket {
  transportType: TransportType;
  origin: string;
  destination: string;
  departureDate: string; // ISO
  trainOrFlightNumber: string;
  seatNumber?: string | null;
  passengerName?: string | null;
  bookingReference?: string | null;
  confidence: number;
}

const SYSTEM_PROMPT = `Tu es un expert en lecture de billets de transport (train SNCF, Eurostar, Thalys, TGV, OUIGO, avion).
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
Si une information est illisible, mets null. confidence = 1.0 si tout est clair, < 0.5 si le billet est très illisible.`;

/**
 * Envoie une image (base64 JPEG, sans préfixe data:) à Claude Vision
 * et retourne les infos du billet.
 */
export async function scanTicket(base64Jpeg: string): Promise<ScannedTicket> {
  if (ANTHROPIC_API_KEY === "VOTRE_CLE_ANTHROPIC") {
    throw new Error(
      "Clé Anthropic manquante : renseigne-la dans lib/scanner.ts"
    );
  }

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: 512,
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: "image/jpeg",
                data: base64Jpeg,
              },
            },
            { type: "text", text: "Analyse ce billet et retourne le JSON." },
          ],
        },
      ],
    }),
  });

  if (!res.ok) {
    const msg = await res.text();
    throw new Error(`Erreur API : ${msg}`);
  }

  const root = await res.json();
  const text: string | undefined = root?.content?.[0]?.text;
  if (!text) throw new Error("Structure API inattendue");

  let ticket: any;
  try {
    ticket = JSON.parse(text.trim());
  } catch {
    throw new Error(`Lecture du billet échouée : ${text}`);
  }

  const confidence = Number(ticket.confidence ?? 0);
  if (confidence < 0.45) {
    throw new Error(
      "Le billet n'est pas lisible. Essaie avec une photo plus nette."
    );
  }

  const origin = String(ticket.origin ?? "");
  const destination = String(ticket.destination ?? "");
  if (!origin || !destination) {
    throw new Error("Départ ou destination introuvable.");
  }

  return {
    transportType: ticket.transport_type === "plane" ? "Avion" : "Train",
    origin,
    destination,
    departureDate: parseDate(ticket.departure_datetime),
    trainOrFlightNumber: String(ticket.train_or_flight_number ?? ""),
    seatNumber: ticket.seat_number ?? null,
    passengerName: ticket.passenger_name ?? null,
    bookingReference: ticket.booking_reference ?? null,
    confidence,
  };
}

function parseDate(str?: string): string {
  if (!str) return new Date().toISOString();
  const d = new Date(str);
  return isNaN(d.getTime()) ? new Date().toISOString() : d.toISOString();
}
