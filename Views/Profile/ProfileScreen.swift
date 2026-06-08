import SwiftUI
import NukeUI
import Pow

struct ProfileScreen: View {
    @State private var vm = ProfileEditViewModel()
    @State private var selectedMode: TravelMode = .love
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader
                        modeSwitcher
                        if selectedMode == .love { loveContent } else { workContent }
                        actions
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEdit) {
                ProfileEditView(mode: selectedMode)
            }
        }
        .background(Color.clear)
        .task { await vm.load() }
    }

    // MARK: - Header

    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Avatar
            avatarView
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(currentName)
                    .font(.rsTitle).foregroundColor(.white)
                Text(currentSubtitle)
                    .font(.rsBody).foregroundColor(.textSecondary)
            }
            Spacer()

            Button(action: { showEdit = true }) {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.12)))
            }
        }
        .glassCard()
        .padding(.top, 16)
    }

    @ViewBuilder
    private var avatarView: some View {
        let urlStr = selectedMode == .love ? vm.lovePhotos.first : (vm.workPhoto.isEmpty ? nil : vm.workPhoto)
        if let str = urlStr, let url = URL(string: str) {
            LazyImage(url: url) { state in
                if let img = state.image { img.resizable().scaledToFill() }
                else { placeholderAvatar }
            }
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.glassStroke, lineWidth: 1))
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        Circle()
            .fill(LinearGradient(colors: selectedMode.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                Text(String(currentName.prefix(1)))
                    .font(.rsTitle).foregroundColor(.white)
            )
    }

    private var currentName: String {
        selectedMode == .love ? (vm.loveName.isEmpty ? "Ton prénom" : vm.loveName)
                              : (vm.workName.isEmpty ? "Ton nom" : vm.workName)
    }

    private var currentSubtitle: String {
        selectedMode == .love
            ? "\(vm.loveAge) ans • \(vm.loveNationality)"
            : "\(vm.workJobTitle) @ \(vm.workCompany)"
    }

    // MARK: - Sélecteur de mode

    private var modeSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(TravelMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) { selectedMode = mode }
                }) {
                    HStack(spacing: 6) {
                        Text(mode.emoji)
                        Text(mode.label)
                            .font(.rsHeadline)
                    }
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selectedMode == mode
                                  ? LinearGradient(colors: mode.gradientColors, startPoint: .leading, endPoint: .trailing)
                                  : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
                    )
                    .foregroundColor(selectedMode == mode ? .white : .textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.glassStroke, lineWidth: 0.8)
                )
        )
    }

    // MARK: - Contenu LOVE

    @ViewBuilder
    private var loveContent: some View {
        if !vm.loveBio.isEmpty {
            infoCard(title: "À propos") {
                Text(vm.loveBio).font(.rsBody).foregroundColor(.textSecondary)
            }
        }
        if !vm.loveInterests.isEmpty {
            infoCard(title: "Centres d'intérêt") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.loveInterests, id: \.self) { i in Text(i).pillTag() }
                    }
                }
            }
        }
        if vm.loveName.isEmpty {
            incompleteProfileBanner(mode: .love)
        }
    }

    // MARK: - Contenu WORK

    @ViewBuilder
    private var workContent: some View {
        if !vm.workBioPro.isEmpty {
            infoCard(title: "Bio professionnelle") {
                Text(vm.workBioPro).font(.rsBody).foregroundColor(.textSecondary)
            }
        }
        if !vm.workSkills.isEmpty {
            infoCard(title: "Compétences") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.workSkills, id: \.self) { s in
                            Text(s).pillTag(color: Color.majorelleBlue.opacity(0.3))
                        }
                    }
                }
            }
        }
        if vm.workName.isEmpty {
            incompleteProfileBanner(mode: .work)
        }
    }

    // MARK: - Bannière profil incomplet

    private func incompleteProfileBanner(mode: TravelMode) -> some View {
        Button(action: { selectedMode = mode; showEdit = true }) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(mode.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Profil \(mode.label) incomplet")
                        .font(.rsHeadline).foregroundColor(.white)
                    Text("Complete-le pour être visible sur tes trajets")
                        .font(.rsCaption).foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.textSecondary)
            }
            .glassCard()
            .overlay(
                RoundedRectangle(cornerRadius: 20).strokeBorder(mode.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private var actions: some View {
        Button(role: .destructive, action: {
            Task { try? await SupabaseService.shared.signOut() }
        }) {
            Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.rsBody).foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .glassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Carte info

    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.rsCaption).foregroundColor(.textSecondary).textCase(.uppercase).tracking(1)
            content()
        }
        .glassCard()
    }
}
