import SwiftUI
import PhotosUI

// MARK: - Vue principale

struct TicketScannerView: View {
    @Binding var isPresented: Bool
    var onTicketScanned: (ScannedTicket) -> Void

    @State private var phase: ScanPhase = .idle
    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var errorMessage: String?

    private let service = TicketScannerService()

    enum ScanPhase {
        case idle
        case scanning
        case result(ScannedTicket)
        case error(String)
    }

    var body: some View {
        ZStack {
            // Fond
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 0) {
                sheetHandle
                    .padding(.top, 12)

                switch phase {
                case .idle:          idleView
                case .scanning:      scanningView
                case .result(let t): resultView(ticket: t)
                case .error(let e):  errorView(message: e)
                }
            }
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await loadAndScan(item: item) }
        }
    }

    // MARK: - Handle

    private var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.3))
            .frame(width: 40, height: 5)
    }

    // MARK: - Phase : Idle

    private var idleView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration billet
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 260, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.majorelleBlue, Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                VStack(spacing: 10) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.majorelleBlue, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Billet de train ou d'avion")
                        .font(.rsCaption)
                        .foregroundColor(.textSecondary)
                }
            }

            VStack(spacing: 8) {
                Text("Scanne ton billet")
                    .font(.rsTitle)
                    .foregroundColor(.white)

                Text("Prends en photo ton billet SNCF, OUIGO,\nThalys ou ta carte d'embarquement.")
                    .font(.rsBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Boutons
            VStack(spacing: 14) {
                // Photo library
                PhotosPicker(
                    selection: $pickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Choisir dans la galerie", systemImage: "photo.on.rectangle.angled")
                        .font(.rsHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.majorelleBlue)
                        )
                }

                Button(action: { showCamera = true }) {
                    Label("Prendre une photo", systemImage: "camera.fill")
                        .font(.rsHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(Color.glassStroke, lineWidth: 1)
                                )
                        )
                }
                .fullScreenCover(isPresented: $showCamera) {
                    CameraPickerView { image in
                        Task { await scan(image: image) }
                    }
                }

                Button(action: { isPresented = false }) {
                    Text("Saisir manuellement")
                        .font(.rsBody)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Phase : Scanning

    private var scanningView: some View {
        VStack(spacing: 40) {
            Spacer()
            ScanBeamAnimation()
                .frame(width: 260, height: 180)
            VStack(spacing: 10) {
                Text("Analyse en cours...")
                    .font(.rsTitle)
                    .foregroundColor(.white)
                Text("Claude lit ton billet")
                    .font(.rsBody)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Phase : Résultat

    @ViewBuilder
    private func resultView(ticket: ScannedTicket) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête succès
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Billet reconnu")
                            .font(.rsHeadline)
                            .foregroundColor(.white)
                        Text("Confiance : \(Int(ticket.confidence * 100))%")
                            .font(.rsCaption)
                            .foregroundColor(ticket.confidence > 0.8 ? .green : .orange)
                    }
                    Spacer()
                    if let ref = ticket.bookingReference {
                        Text(ref)
                            .font(.rsCaption)
                            .pillTag(color: Color.majorelleBlue.opacity(0.4))
                    }
                }
                .glassCard()

                // Champs extraits
                VStack(spacing: 14) {
                    ticketRow(icon: "record.circle",
                              label: "Départ",
                              value: ticket.origin)

                    Divider().background(Color.glassStroke)

                    ticketRow(icon: "mappin.and.ellipse",
                              label: "Destination",
                              value: ticket.destination)

                    Divider().background(Color.glassStroke)

                    ticketRow(icon: "calendar",
                              label: "Date & Heure",
                              value: ticket.departureDate.formatted(date: .abbreviated, time: .shortened))

                    Divider().background(Color.glassStroke)

                    ticketRow(icon: ticket.transportType == .train ? "train.side.front.car" : "airplane",
                              label: ticket.transportType == .train ? "Train" : "Vol",
                              value: ticket.trainOrFlightNumber)

                    if let seat = ticket.seatNumber {
                        Divider().background(Color.glassStroke)
                        ticketRow(icon: "chair.lounge", label: "Siège", value: seat)
                    }

                    if let name = ticket.passengerName {
                        Divider().background(Color.glassStroke)
                        ticketRow(icon: "person.fill", label: "Passager", value: name)
                    }
                }
                .glassCard()

                // Avertissement si confidence moyenne
                if ticket.confidence < 0.8 {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Certaines informations peuvent être inexactes. Vérifie avant de confirmer.")
                            .font(.rsCaption)
                            .foregroundColor(.orange)
                    }
                    .glassCard()
                }

                // Boutons
                VStack(spacing: 12) {
                    Button(action: {
                        onTicketScanned(ticket)
                        isPresented = false
                    }) {
                        Label("Utiliser ce billet", systemImage: "checkmark.circle.fill")
                            .font(.rsHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.majorelleBlue)
                            )
                    }

                    Button(action: { phase = .idle }) {
                        Text("Rescanner")
                            .font(.rsBody)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Phase : Erreur

    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Billet illisible")
                    .font(.rsTitle)
                    .foregroundColor(.white)
                Text(message)
                    .font(.rsBody)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { phase = .idle }) {
                Label("Réessayer", systemImage: "arrow.clockwise")
                    .font(.rsHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.majorelleBlue)
                    )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func ticketRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.majorelleBlue)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.rsCaption)
                    .foregroundColor(.textSecondary)
                Text(value)
                    .font(.rsHeadline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }

    private func loadAndScan(item: PhotosPickerItem) async {
        guard let data  = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await scan(image: image)
    }

    private func scan(image: UIImage) async {
        withAnimation(.spring()) { phase = .scanning }
        do {
            let ticket = try await service.scan(image: image)
            withAnimation(.spring(response: 0.45)) { phase = .result(ticket) }
        } catch {
            withAnimation(.spring()) { phase = .error(error.localizedDescription) }
        }
    }
}

// MARK: - Animation de scan

struct ScanBeamAnimation: View {
    @State private var beamOffset: CGFloat = -80

    var body: some View {
        ZStack {
            // Cadre du billet
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.majorelleBlue.opacity(0.6), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )

            // Coins lumineux
            CornerBrackets()
                .foregroundColor(Color.majorelleBlue)

            // Faisceau de scan
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.majorelleBlue.opacity(0),
                            Color.majorelleBlue.opacity(0.8),
                            Color.majorelleBlue.opacity(0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .offset(y: beamOffset)
                .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
            ) {
                beamOffset = 80
            }
        }
    }
}

struct CornerBrackets: View {
    let size: CGFloat = 20
    let thickness: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 12

            Path { p in
                // Coin haut-gauche
                p.move(to: CGPoint(x: pad, y: pad + size))
                p.addLine(to: CGPoint(x: pad, y: pad))
                p.addLine(to: CGPoint(x: pad + size, y: pad))
                // Coin haut-droit
                p.move(to: CGPoint(x: w - pad - size, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad))
                p.addLine(to: CGPoint(x: w - pad, y: pad + size))
                // Coin bas-droit
                p.move(to: CGPoint(x: w - pad, y: h - pad - size))
                p.addLine(to: CGPoint(x: w - pad, y: h - pad))
                p.addLine(to: CGPoint(x: w - pad - size, y: h - pad))
                // Coin bas-gauche
                p.move(to: CGPoint(x: pad + size, y: h - pad))
                p.addLine(to: CGPoint(x: pad, y: h - pad))
                p.addLine(to: CGPoint(x: pad, y: h - pad - size))
            }
            .stroke(style: StrokeStyle(lineWidth: thickness, lineCap: .round))
        }
    }
}

// MARK: - Wrapper caméra UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage { onCapture(image) }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
