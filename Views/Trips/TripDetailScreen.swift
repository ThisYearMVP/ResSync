import SwiftUI

struct TripDetailScreen: View {
    let trip: Trip
    let mode: TravelMode
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.85), Color.majorelleDark],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                // Sélecteur d'onglet
                Picker("", selection: $selectedTab) {
                    Text("Voyageurs").tag(0)
                    Text("Messages").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                // Contenu
                if selectedTab == 0 {
                    PeopleScreen(trip: trip, mode: mode)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                } else {
                    ConversationListScreen(trip: trip, mode: mode)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
    }

    private var header: some View {
        HStack(spacing: 12) {
            BackButton()

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(mode.emoji)
                    Text("\(trip.origin) → \(trip.destination)")
                        .font(.rsHeadline).foregroundColor(.white)
                }
                Text("Mode \(mode.label) • \(trip.date.formatted(.dateTime.day().month()))")
                    .font(.rsCaption).foregroundColor(.textSecondary)
            }

            Spacer()

            // Badge mode
            Text(mode.label)
                .font(.rsCaption)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(mode.accentColor.opacity(0.2)))
                .foregroundColor(mode.accentColor)
                .overlay(Capsule().strokeBorder(mode.accentColor.opacity(0.4), lineWidth: 1))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
