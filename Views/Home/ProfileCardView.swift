import SwiftUI

struct ProfileCardView: View {
    let user: User
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Image de fond plein écran
                Group {
                    if let photoURL = user.photoURLs.first, let url = URL(string: photoURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                    } else {
                        ZStack {
                            Color.secondary.opacity(0.1)
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(100)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                
                // Dégradé noir pour la lisibilité du texte
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Informations utilisateur
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(user.name)
                                    .font(.system(size: 32, weight: .bold))
                                Text("\(user.age)")
                                    .font(.system(size: 28, weight: .light))
                            }
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(user.nationality)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        // Icône de l'activité du trajet
                        if let trip = user.currentTrip {
                            VStack {
                                Image(systemName: trip.activity.icon)
                                    .font(.title)
                                Text(trip.activity.rawValue)
                                    .font(.caption2)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    Text(user.bio)
                        .font(.body)
                        .lineLimit(2)
                    
                    // Centres d'intérêt
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(user.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(24)
                .foregroundColor(.white)
            }
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
