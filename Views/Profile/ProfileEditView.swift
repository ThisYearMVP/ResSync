import SwiftUI
import PhotosUI
import AlertToast

struct ProfileEditView: View {
    let mode: TravelMode
    @State private var vm = ProfileEditViewModel()
    @State private var showToast = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.88), Color.majorelleDark],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.white.opacity(0.12)))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text(mode.emoji)
                        Text("Profil \(mode.label)")
                            .font(.rsHeadline).foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            if mode == .love { await vm.saveLove() }
                            else             { await vm.saveWork() }
                            showToast = true
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            dismiss()
                        }
                    }) {
                        Text("Sauver")
                            .font(.rsHeadline).foregroundColor(mode.accentColor)
                    }
                    .disabled(vm.isSaving)
                }
                .padding(.horizontal, 20).padding(.vertical, 14)

                ScrollView {
                    VStack(spacing: 16) {
                        if mode == .love { loveForm } else { workForm }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 60)
                }
            }
        }
        .task { await vm.load() }
        .toast(isPresenting: $showToast) {
            AlertToast(
                displayMode: .hud,
                type: .complete(mode.accentColor),
                title: "Profil sauvegardé !",
                style: .style(backgroundColor: Color.majorelleDark, titleColor: .white, titleFont: .rsBody)
            )
        }
    }

    // MARK: - Formulaire LOVE

    @ViewBuilder
    private var loveForm: some View {
        editSection("Identité") {
            RSEditField(label: "Prénom",       value: $vm.loveName)
            RSEditField(label: "Nationalité",  value: $vm.loveNationality)
            HStack {
                Text("Âge").font(.rsBody).foregroundColor(.textSecondary)
                Spacer()
                Stepper("\(vm.loveAge) ans", value: $vm.loveAge, in: 18...100)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }

        editSection("Bio") {
            ZStack(alignment: .topLeading) {
                if vm.loveBio.isEmpty {
                    Text("Quelques mots sur toi...").foregroundColor(.textSecondary).padding(4)
                }
                TextEditor(text: $vm.loveBio)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .frame(minHeight: 80)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
        }

        editSection("Centres d'intérêt (\(vm.loveInterests.count)/6)") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(vm.interestOptions, id: \.self) { i in
                    let sel = vm.loveInterests.contains(i)
                    Button(action: { vm.toggleInterest(i) }) {
                        Text(i)
                            .font(.rsCaption).padding(.horizontal, 12).padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 8).fill(sel ? Color.red : Color.white.opacity(0.08)))
                            .foregroundColor(sel ? .white : .textSecondary)
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2), value: sel)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
    }

    // MARK: - Formulaire WORK

    @ViewBuilder
    private var workForm: some View {
        editSection("Identité professionnelle") {
            RSEditField(label: "Nom complet",  value: $vm.workName)
            RSEditField(label: "Titre de poste", value: $vm.workJobTitle)
            RSEditField(label: "Entreprise",   value: $vm.workCompany)
        }

        editSection("Bio professionnelle") {
            ZStack(alignment: .topLeading) {
                if vm.workBioPro.isEmpty {
                    Text("Décris ton activité...").foregroundColor(.textSecondary).padding(4)
                }
                TextEditor(text: $vm.workBioPro)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .frame(minHeight: 80)
            }
            .padding(.horizontal, 16).padding(.vertical, 8)
        }

        editSection("Compétences (\(vm.workSkills.count)/8)") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(vm.skillOptions, id: \.self) { s in
                    let sel = vm.workSkills.contains(s)
                    Button(action: { vm.toggleSkill(s) }) {
                        Text(s)
                            .font(.rsCaption).padding(.horizontal, 12).padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 8).fill(sel ? Color.majorelleBlue : Color.white.opacity(0.08)))
                            .foregroundColor(sel ? .white : .textSecondary)
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2), value: sel)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
    }

    // MARK: - Section wrapper

    private func editSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.rsCaption).foregroundColor(.textSecondary).textCase(.uppercase).tracking(1)
                .padding(.horizontal, 4).padding(.bottom, 8)
            VStack(spacing: 0) { content() }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.glassStroke, lineWidth: 0.8))
                )
        }
    }
}

// MARK: - Champ d'édition simple

struct RSEditField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(label).font(.rsBody).foregroundColor(.textSecondary).frame(width: 110, alignment: .leading)
                TextField(label, text: $value)
                    .font(.rsBody).foregroundColor(.white)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            Divider().background(Color.glassStroke.opacity(0.5)).padding(.leading, 16)
        }
    }
}
