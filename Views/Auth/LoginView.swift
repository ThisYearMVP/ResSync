import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showSignUp = false

    var body: some View {
        @Bindable var auth = viewModel
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        logoSection
                            .padding(.top, 64)
                            .padding(.bottom, 40)

                        formSection(auth: auth)
                            .padding(.horizontal, 24)

                        dividerSection
                            .padding(.vertical, 24)
                            .padding(.horizontal, 24)

                        ssoButton
                            .padding(.horizontal, 24)

                        signupLink
                            .padding(.top, 32)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.7)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.red.opacity(0.35), radius: 16, y: 6)
                Image(systemName: "train.side.front.car")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            Text("ResSync")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("Ton voisin de trajet t'attend.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Formulaire

    private func formSection(auth: Bindable<AuthViewModel>) -> some View {
        VStack(spacing: 14) {
            FloatingLabelField(
                label: "Adresse e-mail", text: auth.email,
                icon: "envelope", keyboardType: .emailAddress, isSecure: false
            )
            FloatingLabelField(
                label: "Mot de passe", text: auth.password,
                icon: "lock", keyboardType: .default, isSecure: true
            )

            if !viewModel.errorMessage.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                    Text(viewModel.errorMessage).font(.caption).foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Spacer()
                Button("Mot de passe oublié ?") {}
                    .font(.caption).foregroundColor(.secondary)
            }

            Button(action: { Task { await viewModel.signIn() } }) {
                ZStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    else { Text("Se connecter").font(.system(size: 16, weight: .semibold)) }
                }
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.red)
                        .shadow(color: Color.red.opacity(0.3), radius: 10, y: 4)
                )
                .foregroundColor(.white)
            }
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .opacity(viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: viewModel.email.isEmpty)
        }
    }

    // MARK: - Séparateur

    private var dividerSection: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color(.separator)).frame(height: 1)
            Text("ou").font(.caption).foregroundColor(.secondary).fixedSize()
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
    }

    // MARK: - Google SSO

    private var ssoButton: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: "globe").font(.system(size: 18))
                Text("Continuer avec Google").font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity).frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color(.separator), lineWidth: 1)
            )
            .foregroundColor(.primary)
        }
    }

    // MARK: - Lien inscription

    private var signupLink: some View {
        HStack(spacing: 4) {
            Text("Pas encore de compte ?").font(.subheadline).foregroundColor(.secondary)
            Button("Créer un compte") { showSignUp = true }
                .font(.subheadline.bold()).foregroundColor(.red)
        }
    }
}

// MARK: - Champ avec label flottant

struct FloatingLabelField: View {
    let label: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(focused ? .red : Color(.tertiaryLabel))
                .frame(width: 20)

            ZStack(alignment: .leading) {
                Text(label)
                    .font(focused || !text.isEmpty
                          ? .system(size: 11, weight: .medium)
                          : .system(size: 15))
                    .foregroundColor(focused ? .red : Color(.tertiaryLabel))
                    .offset(y: focused || !text.isEmpty ? -12 : 0)
                    .animation(.spring(response: 0.25), value: focused || !text.isEmpty)

                Group {
                    if isSecure { SecureField("", text: $text) }
                    else {
                        TextField("", text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                }
                .focused($focused)
                .offset(y: focused || !text.isEmpty ? 8 : 0)
                .font(.system(size: 15))
                .animation(.spring(response: 0.25), value: focused || !text.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(focused ? Color.red.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focused)
        .onTapGesture { focused = true }
    }
}
