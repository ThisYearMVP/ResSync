import SwiftUI
import Pow

struct ModePickerScreen: View {
    let trip: Trip
    @State private var selectedMode: TravelMode?
    @State private var navigating = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.9), Color.majorelleDark],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    BackButton()
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(trip.origin) → \(trip.destination)")
                            .font(.rsHeadline).foregroundColor(.white)
                        Text(trip.date.formatted(.dateTime.day().month().hour().minute()))
                            .font(.rsCaption).foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Circle().fill(.clear).frame(width: 40)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)

                Spacer()

                VStack(spacing: 12) {
                    Text("Comment tu voyages ?")
                        .font(.rsDisplay).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Choisis ton profil pour ce trajet.\nTu pourras changer à tout moment.")
                        .font(.rsBody).foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)

                // Cartes de mode
                VStack(spacing: 16) {
                    ForEach(TravelMode.allCases, id: \.self) { mode in
                        ModeCard(mode: mode, isSelected: selectedMode == mode) {
                            withAnimation(.spring(response: 0.35)) { selectedMode = mode }
                        }
                        .transition(.movingParts.slide)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // CTA
                NavigationLink(
                    destination: selectedMode.map { TripDetailScreen(trip: trip, mode: $0) },
                    isActive: $navigating
                ) { EmptyView() }

                Button(action: {
                    guard selectedMode != nil else { return }
                    Task {
                        if let mode = selectedMode {
                            try? await SupabaseService.shared.joinTrip(tripId: trip.id, mode: mode)
                        }
                        navigating = true
                    }
                }) {
                    HStack(spacing: 10) {
                        if let mode = selectedMode {
                            Text(mode.emoji)
                            Text("Continuer en mode \(mode.label)")
                                .font(.rsHeadline)
                        } else {
                            Text("Choisir un mode")
                                .font(.rsHeadline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(selectedMode != nil
                                  ? LinearGradient(colors: selectedMode!.gradientColors, startPoint: .leading, endPoint: .trailing)
                                  : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: selectedMode != nil ? selectedMode!.accentColor.opacity(0.35) : .clear, radius: 10, y: 4)
                    )
                }
                .disabled(selectedMode == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 44)
                .animation(.spring(response: 0.3), value: selectedMode)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Carte de mode

struct ModeCard: View {
    let mode: TravelMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                // Icône
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: mode.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Text(mode.emoji)
                        .font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Mode \(mode.label)")
                        .font(.rsHeadline).foregroundColor(.white)
                    Text(mode.description)
                        .font(.rsBody).foregroundColor(.textSecondary)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? mode.accentColor : Color.glassStroke, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if isSelected {
                        Circle()
                            .fill(mode.accentColor)
                            .frame(width: 14, height: 14)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.25), value: isSelected)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected
                          ? LinearGradient(colors: mode.gradientColors.map { $0.opacity(0.18) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.white.opacity(0.07), Color.white.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(isSelected ? mode.accentColor.opacity(0.5) : Color.glassStroke, lineWidth: isSelected ? 1.5 : 0.8)
                    )
            )
            .shadow(color: isSelected ? mode.accentColor.opacity(0.2) : .clear, radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
