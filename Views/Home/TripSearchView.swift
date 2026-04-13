import SwiftUI

/// Écran de recherche de trajet.
struct TripSearchView: View {
    @State private var viewModel = TripSearchViewModel()
    @State private var showFeed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Votre Itinéraire") {
                    TextField("Origine", text: $viewModel.origin)
                    TextField("Destination", text: $viewModel.destination)
                    DatePicker("Date du voyage", selection: $viewModel.date, displayedComponents: .date)
                }
                
                Section("Préférences") {
                    Picker("Transport", selection: $viewModel.transport) {
                        ForEach(TransportType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    
                    Picker("Activité souhaitée", selection: $viewModel.activity) {
                        ForEach(ActivityType.allCases, id: \.self) { act in
                            Label(act.rawValue, systemImage: act.icon).tag(act)
                        }
                    }
                }
                
                Button(action: { showFeed = true }) {
                    Text("Rechercher des voyageurs")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .padding(.top)
            }
            .navigationTitle("Nouveau voyage")
            .navigationDestination(isPresented: $showFeed) {
                FeedView(searchTrip: viewModel.getTrip())
            }
        }
    }
}
