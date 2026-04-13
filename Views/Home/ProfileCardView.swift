import SwiftUI

/// Vue affichant une carte de profil pour le feed.
struct ProfileCardView: View {
    let user: User
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Photo de l'utilisateur (Placeholder si vide)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(0.7, contentMode: .fill)
                .overlay {
                    if let photoURL = user.photoURLs.first {
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(100)
                            .foregroundColor(.white)
                    }
                }
                .clipped()
            
            // Dégradé pour la lisibilité
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(user.name), \(user.age)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(user.nationality)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let trip = user.currentTrip {
                        Image(systemName: trip.activity.icon)
                            .font(.title2)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                
                Text(user.bio)
                    .lineLimit(2)
                    .font(.subheadline)
                
                // Tags des centres d'intérêt
                HStack {
                    ForEach(user.interests.prefix(3), id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
            }
            .padding(20)
            .foregroundColor(.white)
        }
        .cornerRadius(20)
        .padding()
    }
}
