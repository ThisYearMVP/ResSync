// ── Travel mode ────────────────────────────────────────────────
export type TravelMode = "love" | "work";

export const MODE_META: Record<
  TravelMode,
  {
    label: string;
    emoji: string;
    description: string;
    accent: string;
    gradient: [string, string];
  }
> = {
  love: {
    label: "LOVE",
    emoji: "💛",
    description: "Rencontres et liens personnels",
    accent: "#FFCC1A",
    gradient: ["#FF734D", "#FF3380"],
  },
  work: {
    label: "WORK",
    emoji: "💼",
    description: "Networking et collaborations",
    accent: "#3380FF",
    gradient: ["#2659E6", "#0D268C"],
  },
};

// ── Transports & activités ─────────────────────────────────────
export type TransportType = "Train" | "Avion";
export const TRANSPORTS: { value: TransportType; icon: string }[] = [
  { value: "Train", icon: "🚆" },
  { value: "Avion", icon: "✈️" },
];

export type ActivityType =
  | "Travailler"
  | "Parler"
  | "Se reposer"
  | "Jouer"
  | "Autre";
export const ACTIVITIES: { value: ActivityType; icon: string }[] = [
  { value: "Travailler", icon: "💻" },
  { value: "Parler", icon: "💬" },
  { value: "Se reposer", icon: "😴" },
  { value: "Jouer", icon: "🎮" },
  { value: "Autre", icon: "✨" },
];

// ── Trip ───────────────────────────────────────────────────────
export interface Trip {
  id: string;
  origin: string;
  destination: string;
  date: string; // ISO
  transport: TransportType;
  activity: ActivityType;
}

// ── Profils ────────────────────────────────────────────────────
export interface ProfileLove {
  id?: string;
  user_id?: string;
  name: string;
  age: number;
  nationality: string;
  bio: string;
  interests: string[];
  photos: string[];
}

export interface ProfileWork {
  id?: string;
  user_id?: string;
  name: string;
  job_title: string;
  company: string;
  bio_pro: string;
  skills: string[];
  photo: string;
}

// ── Participants & réactions ───────────────────────────────────
export interface TripParticipant {
  id?: string;
  trip_id: string;
  user_id: string;
  mode: TravelMode;
  joined_at?: string;
  // dénormalisé pour l'affichage
  profileLove?: ProfileLove | null;
  profileWork?: ProfileWork | null;
}

export type ReactionType = "wave" | "coffee" | "chat";
export const REACTIONS: { value: ReactionType; emoji: string; label: string }[] =
  [
    { value: "wave", emoji: "👋", label: "Bonjour" },
    { value: "coffee", emoji: "☕", label: "Café ?" },
    { value: "chat", emoji: "💬", label: "Discuter" },
  ];

export function emptyLove(): ProfileLove {
  return {
    name: "",
    age: 18,
    nationality: "",
    bio: "",
    interests: [],
    photos: [],
  };
}

export function emptyWork(): ProfileWork {
  return {
    name: "",
    job_title: "",
    company: "",
    bio_pro: "",
    skills: [],
    photo: "",
  };
}
