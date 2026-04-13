import SwiftUI

/// Liste des matchs et conversations en cours.
struct MatchesListView: View {
    var body: some View {
        NavigationStack {
            List {
                // Exemple statique (à lier avec Firestore Match collection)
                NavigationLink(destination: ChatView(userName: "Thomas")) {
                    HStack {
                        Circle().fill(.blue).frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Thomas").fontWeight(.bold)
                            Text("Trajet Paris → Lyon").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}
