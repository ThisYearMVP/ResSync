import { supabase } from "./supabase";
import type {
  Trip,
  TravelMode,
  ProfileLove,
  ProfileWork,
  TripParticipant,
  ReactionType,
} from "./types";

async function currentUserId(): Promise<string | null> {
  const { data } = await supabase.auth.getSession();
  return data.session?.user.id ?? null;
}

// ── Profils LOVE ───────────────────────────────────────────────
export async function fetchProfileLove(
  userId: string
): Promise<ProfileLove | null> {
  const { data, error } = await supabase
    .from("profiles_love")
    .select("*")
    .eq("user_id", userId);
  if (error) throw error;
  return data?.[0] ?? null;
}

export async function saveProfileLove(profile: ProfileLove) {
  const userId = await currentUserId();
  const { error } = await supabase
    .from("profiles_love")
    .upsert({ ...profile, user_id: userId }, { onConflict: "user_id" });
  if (error) throw error;
}

// ── Profils WORK ───────────────────────────────────────────────
export async function fetchProfileWork(
  userId: string
): Promise<ProfileWork | null> {
  const { data, error } = await supabase
    .from("profiles_work")
    .select("*")
    .eq("user_id", userId);
  if (error) throw error;
  return data?.[0] ?? null;
}

export async function saveProfileWork(profile: ProfileWork) {
  const userId = await currentUserId();
  const { error } = await supabase
    .from("profiles_work")
    .upsert({ ...profile, user_id: userId }, { onConflict: "user_id" });
  if (error) throw error;
}

// ── Trajets ────────────────────────────────────────────────────
export async function saveUserTrip(trip: Omit<Trip, "id">) {
  const userId = await currentUserId();
  if (!userId) throw new Error("Non connecté");
  const { error } = await supabase.from("user_trips").insert({
    user_id: userId,
    origin: trip.origin,
    destination: trip.destination,
    departure_time: trip.date,
    transport_type: trip.transport,
    activity_type: trip.activity,
  });
  if (error) throw error;
}

export async function fetchUserTrips(): Promise<Trip[]> {
  const userId = await currentUserId();
  if (!userId) return [];
  const { data, error } = await supabase
    .from("user_trips")
    .select("*")
    .eq("user_id", userId)
    .order("departure_time", { ascending: true });
  if (error) throw error;
  return (data ?? []).map((r: any) => ({
    id: r.id,
    origin: r.origin,
    destination: r.destination,
    date: r.departure_time,
    transport: r.transport_type,
    activity: r.activity_type,
  }));
}

// ── Participants ───────────────────────────────────────────────
export async function joinTrip(tripId: string, mode: TravelMode) {
  const userId = await currentUserId();
  if (!userId) return;
  const { error } = await supabase
    .from("trip_participants")
    .upsert(
      { trip_id: tripId, user_id: userId, mode },
      { onConflict: "trip_id,user_id" }
    );
  if (error) throw error;
}

export async function fetchParticipants(
  tripId: string,
  mode: TravelMode
): Promise<TripParticipant[]> {
  const { data, error } = await supabase
    .from("trip_participants")
    .select("*")
    .eq("trip_id", tripId)
    .eq("mode", mode);
  if (error) throw error;
  return (data ?? []) as TripParticipant[];
}

export async function fetchProfilesLove(
  userIds: string[]
): Promise<ProfileLove[]> {
  if (userIds.length === 0) return [];
  const { data, error } = await supabase
    .from("profiles_love")
    .select("*")
    .in("user_id", userIds);
  if (error) throw error;
  return (data ?? []) as ProfileLove[];
}

export async function fetchProfilesWork(
  userIds: string[]
): Promise<ProfileWork[]> {
  if (userIds.length === 0) return [];
  const { data, error } = await supabase
    .from("profiles_work")
    .select("*")
    .in("user_id", userIds);
  if (error) throw error;
  return (data ?? []) as ProfileWork[];
}

/** Charge les participants d'un trajet + leurs profils (hors soi-même). */
export async function loadTripPeople(
  tripId: string,
  mode: TravelMode
): Promise<TripParticipant[]> {
  const me = await currentUserId();
  const participants = (await fetchParticipants(tripId, mode)).filter(
    (p) => p.user_id !== me
  );
  const ids = participants.map((p) => p.user_id);
  if (mode === "love") {
    const profiles = await fetchProfilesLove(ids);
    const byId = new Map(profiles.map((p) => [p.user_id, p]));
    return participants.map((p) => ({
      ...p,
      profileLove: byId.get(p.user_id) ?? null,
    }));
  } else {
    const profiles = await fetchProfilesWork(ids);
    const byId = new Map(profiles.map((p) => [p.user_id, p]));
    return participants.map((p) => ({
      ...p,
      profileWork: byId.get(p.user_id) ?? null,
    }));
  }
}

// ── Réactions ──────────────────────────────────────────────────
export async function sendReaction(
  tripId: string,
  toUserId: string,
  reaction: ReactionType
) {
  const fromUserId = await currentUserId();
  if (!fromUserId) return;
  const { error } = await supabase.from("profile_reactions").insert({
    trip_id: tripId,
    from_user_id: fromUserId,
    to_user_id: toUserId,
    reaction,
  });
  if (error) throw error;
}
