import SwiftUI

struct SignUpView: View {
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var auth = viewModel
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                SignUpProgressBar(step: viewModel.currentStep, total: 3)
                    .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(stepTitle)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text(stepSubtitle)
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24).padding(.bottom, 28)

                if !viewModel.errorMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                        Text(viewModel.errorMessage).font(.caption).foregroundColor(.red)
                    }
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.08)).cornerRadius(12)
                    .padding(.horizontal, 24).padding(.bottom, 12)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        switch viewModel.currentStep {
                        case 0: step1(auth: auth)
                        case 1: step2(auth: auth)
                        case 2: step3(auth: auth)
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 120)
                }
                Spacer(minLength: 0)
            }

            VStack {
                Spacer()
                navButtons(auth: auth)
                    .padding(.horizontal, 24).padding(.bottom, 32)
                    .background(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
    }

    // MARK: - Titres

    private var stepTitle: String {
        ["Créer un compte", "Qui es-tu ?", "Tes centres d'intérêt"][safe: viewModel.currentStep] ?? ""
    }
    private var stepSubtitle: String {
        ["Commence par tes identifiants", "Ces infos restent privées", "Choisis entre 3 et 6 intérêts"][safe: viewModel.currentStep] ?? ""
    }

    // MARK: - Étape 1

    @ViewBuilder
    private func step1(auth: Bindable<AuthViewModel>) -> some View {
        FloatingLabelField(label: "Adresse e-mail",           text: auth.email,            icon: "envelope",    keyboardType: .emailAddress, isSecure: false)
        FloatingLabelField(label: "Mot de passe (6 car. min)", text: auth.password,         icon: "lock",        keyboardType: .default,      isSecure: true)
        FloatingLabelField(label: "Confirmer le mot de passe", text: auth.confirmPassword,  icon: "lock.shield", keyboardType: .default,      isSecure: true)
        if !viewModel.password.isEmpty {
            PasswordStrengthBar(password: viewModel.password)
        }
    }

    // MARK: - Étape 2

    @ViewBuilder
    private func step2(auth: Bindable<AuthViewModel>) -> some View {
        HStack(spacing: 12) {
            FloatingLabelField(label: "Prénom", text: auth.firstName, icon: "person",      keyboardType: .default, isSecure: false)
            FloatingLabelField(label: "Nom",    text: auth.lastName,  icon: "person.fill", keyboardType: .default, isSecure: false)
        }
        FloatingLabelField(label: "Nationalité", text: auth.nationality, icon: "globe.europe.africa", keyboardType: .default, isSecure: false)

        HStack {
            Image(systemName: "birthday.cake").foregroundColor(Color(.tertiaryLabel))
            Text("Âge").foregroundColor(.secondary)
            Spacer()
            Stepper("\(viewModel.age) ans", value: auth.age, in: 18...100).fixedSize()
        }
        .padding(.horizontal, 16).frame(height: 56)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    // MARK: - Étape 3

    @ViewBuilder
    private func step3(auth: Bindable<AuthViewModel>) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
            ForEach(viewModel.allInterests, id: \.self) { interest in
                let selected = viewModel.selectedInterests.contains(interest)
                Button(action: { viewModel.toggleInterest(interest) }) {
                    Text(interest)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(selected ? Color.red : Color(.secondarySystemBackground)))
                        .foregroundColor(selected ? .white : .primary)
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(selected ? Color.clear : Color(.separator), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25), value: selected)
            }
        }
        Text("\(viewModel.selectedInterests.count)/6 sélectionnés")
            .font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .trailing)
        FloatingLabelField(label: "Petite bio (optionnel)", text: auth.bio, icon: "text.quote", keyboardType: .default, isSecure: false)
    }

    // MARK: - Navigation

    @ViewBuilder
    private func navButtons(auth: Bindable<AuthViewModel>) -> some View {
        HStack(spacing: 12) {
            if viewModel.currentStep > 0 {
                Button(action: { viewModel.previousStep() }) {
                    Image(systemName: "arrow.left").font(.system(size: 16, weight: .semibold))
                        .frame(width: 52, height: 52)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
                        .foregroundColor(.primary)
                }
            }
            Button(action: {
                if viewModel.currentStep < 2 { viewModel.nextStep() }
                else { Task { await viewModel.signUp() } }
            }) {
                ZStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    else {
                        HStack(spacing: 8) {
                            Text(viewModel.currentStep < 2 ? "Continuer" : "C'est parti !")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: viewModel.currentStep < 2 ? "arrow.right" : "checkmark")
                        }
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isNextEnabled ? Color.red : Color(.systemFill))
                        .shadow(color: isNextEnabled ? Color.red.opacity(0.25) : .clear, radius: 8, y: 3)
                )
                .foregroundColor(isNextEnabled ? .white : Color(.tertiaryLabel))
            }
            .disabled(!isNextEnabled || viewModel.isLoading)
        }
    }

    private var isNextEnabled: Bool {
        switch viewModel.currentStep {
        case 0: return viewModel.isStep1Valid
        case 1: return viewModel.isStep2Valid
        case 2: return viewModel.isStep3Valid
        default: return false
        }
    }
}

// MARK: - Composants partagés Auth

struct SignUpProgressBar: View {
    let step, total: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i <= step ? Color.red : Color(.systemFill))
                    .frame(height: 3)
                    .animation(.spring(response: 0.35), value: step)
            }
        }
    }
}

struct PasswordStrengthBar: View {
    let password: String
    private var strength: Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.contains(where: { $0.isUppercase }) { s += 1 }
        if password.contains(where: { $0.isNumber }) { s += 1 }
        if password.contains(where: { !$0.isLetter && !$0.isNumber }) { s += 1 }
        return s
    }
    private var label: String  { ["Faible","Faible","Moyen","Fort","Très fort"][safe: strength] ?? "" }
    private var color: Color   { [.red, .red, .orange, Color(red:0.2,green:0.7,blue:0.3), .green][safe: strength] ?? .red }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < strength ? color : Color(.systemFill))
                    .frame(height: 3)
                    .animation(.spring(response: 0.3), value: strength)
            }
            Text(label).font(.caption2).foregroundColor(color).frame(width: 56, alignment: .trailing)
        }
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
