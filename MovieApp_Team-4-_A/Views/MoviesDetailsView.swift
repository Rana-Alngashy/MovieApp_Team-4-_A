//
//  MoviesDetailsView.swift
//  Movies
//
//  Created by Danyah ALbarqawi on 24/12/2025.
//

import SwiftUI

// MARK: - Main View
/// The main movie details view that displays comprehensive information about a movie
/// including cover image, metadata, synopsis, director, cast, and user reviews
struct MoviesDetailsView: View {
    
    // MARK: - Properties
    /// The movie record passed from the previous screen
    let movie: MovieRecord
    
    // MARK: - State Properties
    /// Controls whether the movie is bookmarked/saved
    @State private var isBookmarked: Bool = false
    
    /// Stores the saved_movies record ID if bookmarked
    @State private var savedMovieRecordId: String?
    
    /// Reviews loaded from API
    @State private var reviews: [ReviewRecord] = []
    
    /// Controls whether the write review sheet is presented
    @State private var showWriteReview: Bool = false
    
    /// Environment variable to handle navigation back
    @Environment(\.dismiss) private var dismiss
    
    /// API Service instance
    private let apiService = APIService()
    
    /// Current user ID (in real app, get from authentication)
    /// ⚠️ Replace with actual user ID from your auth system
    private let currentUserId = "recPRxIRAyyvQxfkP"
    
    var body: some View {
        ZStack {
            // MARK: Background
            /// Dark background color for the entire view
            Color.black
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Hero Image Section
                    /// Movie cover image with gradient overlay and navigation buttons
                    ZStack(alignment: .top) {
                        // Movie poster image from API
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
                        
                        // Gradient overlay for better text readability
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
                        
                        // MARK: Navigation Bar
                        /// Top navigation with back button, share, and bookmark
                        HStack {
                            // Back button
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Share button
                            Button(action: {
                                // Share action placeholder
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.yellow)
                            }
                            .padding(.trailing, 16)
                            
                            // Bookmark button
                            Button(action: {
                                Task {
                                    await toggleBookmark()
                                }
                            }) {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 50) // Account for status bar
                        
                        // MARK: Movie Title Overlay
                        /// Movie title positioned at the bottom of the hero image
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
                    /// Duration, Language, Genre, and Age rating in a grid layout
                    HStack(alignment: .top, spacing: 40) {
                        // Duration
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.runtime)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Language
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
                        // Genre
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Genre")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text(movie.fields.genre.joined(separator: ", "))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        // Age Rating
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
                    /// Movie synopsis/description
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
                    /// IMDb rating display with underlined label
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
                    
                    // MARK: - Director Section
                    /// Director information displayed as a single image asset
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Director")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Director image asset (already contains circular photo + name)
                        Image("Director")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 346, height: 100)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(width: 346, height: 134, alignment: .topLeading)
                    .padding(.horizontal, 17)
                    .padding(.top, 16)
                    
                    // MARK: - Stars Section
                    /// Cast members displayed as a single image asset
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stars")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Stars image asset (already contains circular photos + names)
                        Image("Stars")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 346, height: 100)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(width: 346, height: 134, alignment: .topLeading)
                    .padding(.horizontal, 17)
                    
                    // Divider line
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // MARK: - Rating & Reviews Section
                    /// User ratings and review cards
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating & Reviews")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Overall rating display
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
                    /// Horizontal scrollable review cards from API
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if reviews.isEmpty {
                                // Placeholder when no reviews
                                Text("No reviews yet. Be the first!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(reviews) { review in
                                    ReviewCard(
                                        profileImage: "",
                                        reviewerName: "User",
                                        rating: (review.fields.rate ?? 0) / 2,
                                        reviewText: review.fields.reviewText ?? "",
                                        date: formatDate(review.createdTime)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    
                    // MARK: - Write Review Button
                    /// Call-to-action button for users to write their own review
                    Button(action: {
                        showWriteReview = true
                    }) {
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
        .task {
            await loadReviews()
            await checkBookmarkStatus()
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewSheet(movieId: movie.id, userId: currentUserId) {
                Task {
                    await loadReviews()
                }
            }
        }
    }
    
    // MARK: - API Functions
    
    /// Loads reviews from API
    private func loadReviews() async {
        do {
            reviews = try await apiService.fetchMovieReviews(movieId: movie.id)
        } catch {
            print("Failed to load reviews: \(error)")
        }
    }
    
    /// Checks if movie is bookmarked
    private func checkBookmarkStatus() async {
        do {
            savedMovieRecordId = try await apiService.checkIfMovieSaved(userId: currentUserId, movieId: movie.id)
            isBookmarked = savedMovieRecordId != nil
        } catch {
            print("Failed to check bookmark: \(error)")
        }
    }
    
    /// Toggles bookmark state
    private func toggleBookmark() async {
        do {
            if isBookmarked, let savedId = savedMovieRecordId {
                try await apiService.unsaveMovie(savedMovieId: savedId)
                isBookmarked = false
                savedMovieRecordId = nil
            } else {
                let newSavedId = try await apiService.saveMovie(userId: currentUserId, movieId: movie.id)
                isBookmarked = true
                savedMovieRecordId = newSavedId
            }
        } catch {
            print("Failed to toggle bookmark: \(error)")
        }
    }
    
    /// Formats ISO date to readable string
    private func formatDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoDate) else { return "" }
        
        let calendar = Calendar.current
        if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day, daysAgo < 7 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    }
}

// MARK: - Supporting Views

/// A card component for displaying user reviews
/// Contains reviewer info, star rating, review text, and date
struct ReviewCard: View {
    /// The image asset name for reviewer's profile picture
    let profileImage: String
    /// The reviewer's display name
    let reviewerName: String
    /// The star rating (1-5)
    let rating: Int
    /// The review text content
    let reviewText: String
    /// The date when the review was posted
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Reviewer Header
            /// Profile picture, name, and star rating
            HStack(spacing: 10) {
                // Reviewer profile image
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.yellow)
                    )
                
                // Reviewer name and rating
                VStack(alignment: .leading, spacing: 2) {
                    if !reviewerName.isEmpty {
                        Text(reviewerName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Star rating display
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
            
            // MARK: Review Text
            /// The actual review content
            Text(reviewText)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // MARK: Date
            /// When the review was posted
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

// MARK: - Write Review Sheet
/// Sheet view for writing a new review
struct WriteReviewSheet: View {
    let movieId: String
    let userId: String
    let onReviewPosted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var reviewText: String = ""
    @State private var rating: Int = 5
    @State private var isSubmitting: Bool = false
    
    private let apiService = APIService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Rating Selector
                    VStack(spacing: 8) {
                        Text("Your Rating")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 30))
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        rating = star
                                    }
                            }
                        }
                    }
                    
                    // Review Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Review")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextEditor(text: $reviewText)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                    }
                    
                    // Submit Button
                    Button(action: {
                        Task {
                            await submitReview()
                        }
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Submit Review")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    .disabled(reviewText.isEmpty || isSubmitting)
                    .opacity(reviewText.isEmpty ? 0.5 : 1)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
    
    /// Submits the review to the API
    private func submitReview() async {
        isSubmitting = true
        
        do {
            // Convert 1-5 rating to 1-10 for API
            let apiRating = rating * 2
            _ = try await apiService.postReview(
                movieId: movieId,
                userId: userId,
                text: reviewText,
                rating: apiRating
            )
            
            await MainActor.run {
                onReviewPosted()
                dismiss()
            }
        } catch {
            print("Failed to submit review: \(error)")
            await MainActor.run {
                isSubmitting = false
            }
        }
    }
}

// MARK: - Preview
/// Preview provider for SwiftUI canvas
struct MoviesDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample movie for preview
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
        
        MoviesDetailsView(movie: sampleMovie)
            .preferredColorScheme(.dark)
    }
}
