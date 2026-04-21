import SwiftUI

struct SignUpView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        @Bindable var auth = viewModel
        VStack {
            ProgressHeader(step: viewModel.currentStep)
                .padding(.top)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    switch viewModel.currentStep {
                    case 0: step1Credentials
                    case 1: step2Identity
                    case 2: step3Interests
                    default: EmptyView()
                    }
                }
                .padding(.horizontal)
            }
            .animation(.easeInOut, value: viewModel.currentStep)
            
            navigationButtons
                .padding()
        }
        .navigationTitle("Inscription")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // --- ÉTAPE 1: IDENTIFIANTS ---
    @ViewBuilder
    var step1Credentials: some View {
        @Bindable var auth = viewModel
        VStack(alignment: .leading, spacing: 20) {
            Text("Commençons par vos identifiants officiels.")
                .font(.headline)
            
            TextField("Email", text: $auth.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            phoneInputField
            
            SecureField("Mot de passe (6 car. min)", text: $auth.password)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirmer le mot de passe", text: $auth.confirmPassword)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    @ViewBuilder
    var phoneInputField: some View {
        @Bindable var auth = viewModel
        VStack(alignment: .leading, spacing: 8) {
            Text("Numéro de téléphone").font(.caption).foregroundColor(.secondary)
            HStack(spacing: 12) {
                Menu {
                    ForEach(viewModel.countries) { country in
                        Button("\(country.flag) \(country.name)") { 
                            viewModel.selectedCountry = country
                            viewModel.phone = "" 
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCountry.flag)
                        Text(viewModel.selectedCountry.code)
                        Image(systemName: "chevron.down").font(.system(size: 10))
                    }
                    .padding(8).background(Color.gray.opacity(0.1)).cornerRadius(8)
                }
                
                ZStack(alignment: .leading) {
                    Text(format(phone: viewModel.phone, with: viewModel.selectedCountry.mask)).foregroundColor(.gray.opacity(0.4))
                    Text(format(phone: viewModel.phone, with: viewModel.selectedCountry.mask, showOnlyEntered: true))
                    TextField("", text: $auth.phone).keyboardType(.numberPad).foregroundColor(.clear)
                        .onChange(of: viewModel.phone) { _, n in
                            viewModel.phone = String(n.filter { $0.isNumber }.prefix(viewModel.selectedCountry.digits))
                        }
                }
                .font(.system(.body, design: .monospaced))
            }
        }
    }
    
    // --- ÉTAPE 2: IDENTITÉ ---
    @ViewBuilder
    var step2Identity: some View {
        @Bindable var auth = viewModel
        VStack(alignment: .leading, spacing: 20) {
            Text("Parlez-nous un peu de vous.")
                .font(.headline)
            
            TextField("Prénom", text: $auth.firstName).textFieldStyle(.roundedBorder)
            TextField("Nom", text: $auth.lastName).textFieldStyle(.roundedBorder)
            Stepper("Âge : \(viewModel.age)", value: $auth.age, in: 18...100)
            TextField("Nationalité", text: $auth.nationality).textFieldStyle(.roundedBorder)
        }
    }
    
    // --- ÉTAPE 3: INTÉRÊTS & QUESTIONS ---
    @ViewBuilder
    var step3Interests: some View {
        @Bindable var auth = viewModel
        VStack(alignment: .leading, spacing: 20) {
            Text("Quels sont vos centres d'intérêt ?")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(viewModel.allInterests, id: \.self) { i in
                    InterestTag(title: i, isSelected: viewModel.selectedInterests.contains(i)) { viewModel.toggleInterest(i) }
                }
            }
            
            Divider()
            
            Text("Vos habitudes en voyage :").font(.headline)
            
            Picker("Plutôt :", selection: $auth.preferredVibe) {
                ForEach(viewModel.vibes, id: \.self) { v in Text(v).tag(v) }
            }.pickerStyle(.segmented)
            
            Picker("Activité favorite :", selection: $auth.travelHabit) {
                ForEach(viewModel.habits, id: \.self) { h in Text(h).tag(h) }
            }.pickerStyle(.menu)
            
            TextField("Petite bio (optionnel)", text: $auth.bio, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
        }
    }
    
    // --- NAVIGATION ---
    var navigationButtons: some View {
        HStack {
            if viewModel.currentStep > 0 {
                Button("Retour") { viewModel.previousStep() }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button(action: {
                if viewModel.currentStep < 2 {
                    viewModel.nextStep()
                } else {
                    Task { await viewModel.signUp() }
                }
            }) {
                HStack {
                    if viewModel.isLoading { ProgressView().tint(.white).padding(.trailing, 5) }
                    Text(viewModel.currentStep < 2 ? "Suivant" : "C'est parti !")
                }
                .padding(.horizontal, 30).padding(.vertical, 12)
                .background(isNextEnabled ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white).cornerRadius(10)
            }
            .disabled(!isNextEnabled || viewModel.isLoading)
        }
    }
    
    var isNextEnabled: Bool {
        switch viewModel.currentStep {
        case 0: return viewModel.isStep1Valid
        case 1: return viewModel.isStep2Valid
        case 2: return viewModel.isStep3Valid
        default: return false
        }
    }
    
    private func format(phone: String, with mask: String, showOnlyEntered: Bool = false) -> String {
        var result = ""; var pIdx = phone.startIndex
        for char in mask {
            if char == "_" {
                if pIdx < phone.endIndex { result.append(phone[pIdx]); pIdx = phone.index(after: pIdx) }
                else { result.append(showOnlyEntered ? " " : "_") }
            } else { result.append(char) }
        }
        return result
    }
}

struct ProgressHeader: View {
    let step: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(i <= step ? Color.blue : Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal)
    }
}
