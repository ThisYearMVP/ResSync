import SwiftUI

struct MyTripsListView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fond transparent pour laisser voir le rouge racine
                Color.clear.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if trips.isEmpty {
                    ContentUnavailableView(
                        "Aucun voyage",
                        systemImage: "calendar.badge.plus",
                        description: Text("Ajoutez un voyage pour rencontrer vos futurs voisins !")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(trips) { trip in
                                NavigationLink(destination: FeedView(searchTrip: trip)) {
                                    TripCard(trip: trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mes Trajets")
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color.clear)
            .refreshable {
                await loadTrips()
            }
            .onAppear {
                Task {
                    await loadTrips()
                }
            }
        }
        .background(Color.clear)
    }
    
    private func loadTrips() async {
        isLoading = true
        do {
            trips = try await SupabaseService.shared.fetchUserTrips()
        } catch {
            print("Erreur chargement trajets : \(error)")
        }
        isLoading = false
    }
}

struct TripCard: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(trip.origin) → \(trip.destination)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(trip.date.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: trip.transport.icon)
                    .font(.title2)
                    .foregroundColor(.majorelleBlue)
            }
            
            HStack {
                Label(trip.activity.rawValue, systemImage: trip.activity.icon)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.majorelleBlue.opacity(0.1))
                    .foregroundColor(.majorelleBlue)
                    .cornerRadius(10)
                
                Spacer()
                
                Text("Voir les voisins")
                    .font(.caption.bold())
                    .foregroundColor(.majorelleBlue)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.majorelleBlue)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
