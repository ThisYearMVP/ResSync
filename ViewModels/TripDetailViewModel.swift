import Foundation
import Observation

@Observable
class TripDetailViewModel {
    var participants: [TripParticipant] = []
    var isLoading = false
    var reactionSent: (TripParticipant, ReactionType)? = nil

    func load(tripId: String, mode: TravelMode) async {
        isLoading = true
        do {
            var raw = try await SupabaseService.shared.fetchParticipants(tripId: tripId, mode: mode)

            // Exclure l'utilisateur courant
            let myId = try? await SupabaseService.shared.client.auth.session?.user.id
            raw = raw.filter { $0.userId != myId }

            let userIds = raw.map { $0.userId }

            if mode == .love {
                let profiles = try await SupabaseService.shared.fetchProfilesLove(userIds: userIds)
                let map = Dictionary(uniqueKeysWithValues: profiles.compactMap { p -> (UUID, ProfileLove)? in
                    guard let uid = p.userId else { return nil }
                    return (uid, p)
                })
                participants = raw.map { p in
                    var copy = p
                    copy.profileLove = map[p.userId]
                    return copy
                }
            } else {
                let profiles = try await SupabaseService.shared.fetchProfilesWork(userIds: userIds)
                let map = Dictionary(uniqueKeysWithValues: profiles.compactMap { p -> (UUID, ProfileWork)? in
                    guard let uid = p.userId else { return nil }
                    return (uid, p)
                })
                participants = raw.map { p in
                    var copy = p
                    copy.profileWork = map[p.userId]
                    return copy
                }
            }
        } catch {
            print("TripDetailViewModel: \(error)")
        }
        isLoading = false
    }

    func sendReaction(_ reaction: ReactionType, to participant: TripParticipant, tripId: String) async {
        do {
            try await SupabaseService.shared.sendReaction(tripId: tripId, toUserId: participant.userId, reaction: reaction)
            reactionSent = (participant, reaction)
        } catch { print("sendReaction: \(error)") }
    }
}
