import SwiftUI

// MARK: - Main View
struct MoviesDetailsView: View {
    
    // MARK: - Properties
    let movie: MovieRecord
    let signedInEmail: String
    
    // MARK: - ViewModel
    @StateObject private var viewModel = MovieDetailsViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Hero Image Section
                    ZStack(alignment: .top) {
                        AsyncImage(url: URL(string: movie.fields.poster)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 390, height: 444)
                                    .overlay(ProgressView().tint(.white))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 390, height: 444)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 390, height: 444)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .clear,
                                Color.black.opacity(0.8),
                                Color.black
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 444)
                        
                        // MARK: Navigation Bar (Buttons)
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.yellow)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6)) // Black Glass
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                shareMovie()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.yellow)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6)) // Black Glass
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 8)
                            
                            Button(action: {
                                Task {
                                    await viewModel.toggleBookmark(movieId: movie.id)
                                }
                            }) {
                                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.yellow)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black.opacity(0.6)) // Black Glass
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 50)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(movie.fields.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        }
                        .frame(height: 444)
                    }
                    
                    // MARK: - Movie Metadata Section
                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.runtime)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Language")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.language.joined(separator: ", "))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Genre")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.genre.joined(separator: ", "))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.rating)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // MARK: - Story Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Story")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(movie.fields.story)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    // MARK: - IMDb Rating Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("IMDb Rating")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%.1f / 10", movie.fields.imdbRating))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    // Divider line
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // MARK: - Director Section (FROM API)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Director")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if viewModel.movieDirectors.isEmpty {
                                    Text("No director info")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                } else {
                                    ForEach(viewModel.movieDirectors) { director in
                                        PersonCard(
                                            name: director.fields.name,
                                            imageURL: director.fields.image
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // MARK: - Stars Section (FROM API)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stars")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if viewModel.movieActors.isEmpty {
                                    Text("No cast info")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                } else {
                                    ForEach(viewModel.movieActors) { actor in
                                        PersonCard(
                                            name: actor.fields.name,
                                            imageURL: actor.fields.image
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Divider line
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // MARK: - Rating & Reviews Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating & Reviews")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%.1f", movie.fields.imdbRating / 2))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("out of 5")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    // MARK: Review Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if viewModel.reviews.isEmpty {
                                Text("No reviews yet. Be the first!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(viewModel.reviews) { review in
                                    ReviewCard(
                                        profileImage: "",
                                        reviewerName: "User",
                                        rating: Int((review.fields.rate ?? 0) / 2),
                                        reviewText: review.fields.reviewText ?? "",
                                        date: viewModel.formatDate(review.createdTime)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    
                    // MARK: - Write Review Button
                    NavigationLink(value: "writeReview") {
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16))
                            Text("Write a review")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: String.self) { value in
            if value == "writeReview" {
                WriteReviewView(
                    movieId: movie.id,
                    userId: viewModel.currentUserId
                )
            }
        }
        .onAppear {
            Task {
                await viewModel.loadAllData(movieId: movie.id, signedInEmail: signedInEmail)
            }
        }
    }
    
    // MARK: - Share Movie
    private func shareMovie() {
        let shareText = "Check out \(movie.fields.name)!"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Person Card (for Directors & Actors)
struct PersonCard: View {
    let name: String
    let imageURL: String?
    
    var body: some View {
        VStack(spacing: 8) {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .overlay(ProgressView().tint(.white))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                    case .failure:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 80)
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let profileImage: String
    let reviewerName: String
    let rating: Int
    let reviewText: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.yellow)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    if !reviewerName.isEmpty {
                        Text(reviewerName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    if rating > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < rating ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
            }
            
            Text(reviewText)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            if !date.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text(date)
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
        }
        .padding(16)
        .frame(width: 300, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
        )
    }
}

// MARK: - Preview
struct MoviesDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFields = MovieFields(
            name: "The Shawshank Redemption",
            poster: "https://i.imghippo.com/files/mHB5371A.jpg",
            story: "Chronicles the experiences of a formerly successful banker as a prisoner in the gloomy jailhouse of Shawshank.",
            runtime: "2h 22m",
            genre: ["Drama"],
            rating: "R",
            imdbRating: 9.3,
            language: ["English"],
            actors: ["Tim Robbins", "Morgan Freeman"]
        )
        let sampleMovie = MovieRecord(id: "recfNj1e4waOUJLxd", fields: sampleFields)
        
        NavigationStack {
            MoviesDetailsView(movie: sampleMovie, signedInEmail: "Noora@gmail.com")
        }
        .preferredColorScheme(.dark)
    }
}
