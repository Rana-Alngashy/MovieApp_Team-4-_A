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
    
    // MARK: - State Properties
    /// Controls whether the movie is bookmarked/saved
    @State private var isBookmarked: Bool = false
    
    /// Environment variable to handle navigation back
    @Environment(\.dismiss) private var dismiss
    
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
                        // Movie poster image
                        Image("Shawshanks cover image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 390, height: 444)
                            .clipped()
                        
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
                                isBookmarked.toggle()
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
                            Text("Shawshank")
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
                            Text("2 hours 22 mins")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Language
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Language")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text("English")
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
                            Text("Drama")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        // Age Rating
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text("+15")
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
                        
                        Text("Synopsis. In 1947, Andy Dufresne (Tim Robbins), a banker in Maine, is convicted of murdering his wife and her lover, a golf pro. Since the state of Maine has no death penalty, he is given two consecutive life sentences and sent to the notoriously harsh Shawshank Prison.")
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
                        
                        Text("9.3 / 10")
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
                        Text("4.8")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("out of 5")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    // MARK: Review Cards
                    /// Horizontal scrollable review cards from users
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // First review card
                            ReviewCard(
                                profileImage: "reviewer1",
                                reviewerName: "Afnan Abdullah",
                                rating: 3,
                                reviewText: "This is an engagingly simple, good-hearted film, with just enough darkness around the edges to give contrast and relief to its glowingly benign view of human nature.",
                                date: "Tuesday"
                            )
                            
                            // Second review card (partially visible)
                            ReviewCard(
                                profileImage: "reviewer2",
                                reviewerName: "",
                                rating: 0,
                                reviewText: "A tough, compas...",
                                date: ""
                            )
                            .frame(width: 80)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    
                    // MARK: - Write Review Button
                    /// Call-to-action button for users to write their own review
                    Button(action: {
                        // Write review action placeholder
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

// MARK: - Preview
/// Preview provider for SwiftUI canvas
struct MoviesDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesDetailsView()
            .preferredColorScheme(.dark)
    }
}
