import SwiftUI

/// Interface de discussion entre deux utilisateurs.
struct ChatView: View {
    let userName: String
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Placeholder messages
                    chatBubble(text: "Salut ! Tu vas à Lyon aussi ?", isCurrentUser: false)
                    chatBubble(text: "Oui, pour le travail. Et toi ?", isCurrentUser: true)
                }
                .padding()
            }
            
            HStack {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: { /* Envoyer message */ }) {
                    Image(systemName: "paperplane.fill")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle(userName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func chatBubble(text: String, isCurrentUser: Bool) -> some View {
        HStack {
            if isCurrentUser { Spacer() }
            Text(text)
                .padding()
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(15)
            if !isCurrentUser { Spacer() }
        }
    }
}
