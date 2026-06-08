import SwiftUI
import Pow

struct MyTripsScreen: View {
    @State private var vm = TripsViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    content
                }
            }
            .navigationBarHidden(true)
        }
        .background(Color.clear)
        .task { await vm.load() }
        .refreshable { await vm.load() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mes Trajets")
                    .font(.rsDisplay)
                    .foregroundColor(.white)
                Text(Date().formatted(.dateTime.weekday(.wide).day().month()))
                    .font(.rsCaption)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Button(action: { showAdd = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.majorelleBlue))
                    .shadow(color: Color.majorelleBlue.opacity(0.4), radius: 8, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Contenu

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            skeletonList
        } else if vm.trips.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(vm.trips) { trip in
                        NavigationLink(destination: ModePickerScreen(trip: trip)) {
                            TripCard(trip: trip)
                        }
                        .buttonStyle(.plain)
                        .transition(.asymmetric(
                            insertion: .movingParts.slide.combined(with: .opacity),
                            removal: .movingParts.vanish
                        ))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Skeleton

    private var skeletonList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.shimmerBase)
                        .frame(height: 110)
                        .shimmering()
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "suitcase.rolling")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.25))
            Text("Aucun voyage")
                .font(.rsTitle).foregroundColor(.textSecondary)
            Text("Ajoute ton premier billet pour rencontrer\ntes voisins de trajet.")
                .font(.rsBody).foregroundColor(.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            Button(action: { showAdd = true }) {
                Label("Ajouter un voyage", systemImage: "plus.circle.fill")
                    .font(.rsHeadline).foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .background(Capsule().fill(Color.majorelleBlue))
            }
            Spacer()
        }
    }
}

// MARK: - Carte de trajet

struct TripCard: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 16) {
            // Icône transport
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.majorelleBlue.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: trip.transport.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color.majorelleBlue)
            }

            VStack(alignment: .leading, spacing: 6) {
                // Trajet
                HStack(spacing: 6) {
                    Text(trip.origin)
                        .font(.rsHeadline).foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .font(.caption).foregroundColor(.textSecondary)
                    Text(trip.destination)
                        .font(.rsHeadline).foregroundColor(.white)
                }
                // Date + activité
                HStack(spacing: 8) {
                    Text(trip.date.formatted(.dateTime.day().month().hour().minute()))
                        .font(.rsCaption).foregroundColor(.textSecondary)
                    Text("•").foregroundColor(.textSecondary)
                    Label(trip.activity.rawValue, systemImage: trip.activity.icon)
                        .font(.rsCaption).foregroundColor(.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.rsCaption)
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.glassStroke, lineWidth: 0.8)
                )
        )
        .shadow(color: Color.cardShadow.opacity(0.5), radius: 10, y: 4)
    }
}
