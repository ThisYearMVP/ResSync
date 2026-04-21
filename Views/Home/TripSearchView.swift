import SwiftUI

struct TripSearchView: View {
    @State private var viewModel = TripSearchViewModel()
    var onTripAdded: () -> Void
    @FocusState private var focusedField: Field?
    @State private var isSaving = false
    
    enum Field { case origin, destination }
    
    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            ZStack {
                AirplaneWindowBackground()
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerSection
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 15) {
                                suggestionTextField(
                                    title: "Départ",
                                    text: $vm.origin,
                                    icon: "record.circle",
                                    suggestions: viewModel.filteredOrigins,
                                    field: .origin
                                )
                                
                                suggestionTextField(
                                    title: "Destination",
                                    text: $vm.destination,
                                    icon: "mappin.and.ellipse",
                                    suggestions: viewModel.filteredDestinations,
                                    field: .destination
                                )
                                
                                CustomDatePicker(selection: $vm.date)
                            }
                            .padding()
                            .background(.white.opacity(0.85))
                            .cornerRadius(20)
                            
                            if viewModel.transport == .train && !viewModel.availableRoutes.isEmpty {
                                schedulePickerSection
                            }
                            
                            VStack(spacing: 15) {
                                CustomTransportPicker(selection: $vm.transport)
                                CustomActivityPicker(selection: $vm.activity)
                            }
                            .padding()
                            .background(.white.opacity(0.85))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal)
                        
                        saveTripButton
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nouveau Voyage")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Où partons-nous ?")
                .font(.title2.bold())
                .foregroundColor(.majorelleBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    var saveTripButton: some View {
        Button(action: {
            Task {
                isSaving = true
                do {
                    try await SupabaseService.shared.saveUserTrip(viewModel.getTrip())
                    withAnimation(.spring()) {
                        onTripAdded()
                    }
                } catch {
                    print("Erreur sauvegarde : \(error)")
                }
                isSaving = false
            }
        }) {
            HStack {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Enregistrer le voyage")
                        .fontWeight(.bold)
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSearchEnabled ? Color.majorelleBlue : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .disabled(!isSearchEnabled || isSaving)
        .padding(.horizontal)
    }

    func suggestionTextField(title: String, text: Binding<String>, icon: String, suggestions: [String], field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(.majorelleBlue)
                TextField(title, text: text)
                    .focused($focusedField, equals: field)
                    .onChange(of: text.wrappedValue) { Task { await viewModel.searchRealRoutes() } }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            if focusedField == field && !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            text.wrappedValue = suggestion
                            focusedField = nil
                        }) {
                            Text(suggestion)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
            }
        }
    }
    
    var schedulePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Horaires TGV").font(.caption.bold()).foregroundColor(.gray)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableRoutes, id: \.self) { route in
                        Button(action: { viewModel.selectedRoute = route }) {
                            VStack {
                                Text(route.departure_time, style: .time).fontWeight(.bold)
                                Text(route.train_number).font(.caption2)
                            }
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(viewModel.selectedRoute == route ? Color.majorelleBlue : Color.gray.opacity(0.1))
                            .foregroundColor(viewModel.selectedRoute == route ? .white : .primary)
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.white.opacity(0.85))
        .cornerRadius(20)
    }
    
    var isSearchEnabled: Bool {
        (viewModel.selectedRoute != nil || viewModel.transport == .plane) && !viewModel.origin.isEmpty && !viewModel.destination.isEmpty
    }
}

// --- SOUS-VUES UTILITAIRES ---

struct CustomDatePicker: View {
    @Binding var selection: Date
    var body: some View {
        HStack {
            Image(systemName: "calendar").foregroundColor(.majorelleBlue)
            DatePicker("Date", selection: $selection, displayedComponents: .date)
                .labelsHidden()
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CustomTransportPicker: View {
    @Binding var selection: TransportType
    var body: some View {
        HStack(spacing: 20) {
            ForEach(TransportType.allCases, id: \.self) { type in
                Button(action: { selection = type }) {
                    VStack {
                        Image(systemName: type.icon).font(.title2)
                        Text(type.rawValue).font(.caption).fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selection == type ? Color.majorelleBlue : Color.clear)
                    .foregroundColor(selection == type ? .white : .gray)
                    .cornerRadius(12)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}

struct CustomActivityPicker: View {
    @Binding var selection: ActivityType
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ActivityType.allCases, id: \.self) { act in
                    Button(action: { selection = act }) {
                        HStack {
                            Image(systemName: act.icon)
                            Text(act.rawValue).font(.caption)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(selection == act ? Color.majorelleBlue : Color.gray.opacity(0.1))
                        .foregroundColor(selection == act ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
}
