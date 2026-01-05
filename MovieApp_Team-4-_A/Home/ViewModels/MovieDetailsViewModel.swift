//
//  MovieDetailsViewModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 05/01/2026.
//
import Foundation
import Combine

@MainActor
class MovieDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isBookmarked: Bool = false
    @Published var savedMovieRecordId: String?
    @Published var reviews: [ReviewRecord] = []
    @Published var currentUserId: String = ""
    @Published var movieActors: [ActorRecord] = []
    @Published var movieDirectors: [DirectorRecord] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private let apiService = APIService()
    
    // MARK: - Load All Data
    func loadAllData(movieId: String, signedInEmail: String) async {
        isLoading = true
        defer { isLoading = false }
        
        // Load actors and directors for this movie
        await loadActorsAndDirectors(movieId: movieId)
        
        // Load user data
        await loadUserData(signedInEmail: signedInEmail, movieId: movieId)
    }
    
    // MARK: - Load Actors and Directors
    private func loadActorsAndDirectors(movieId: String) async {
        do {
            async let actorsTask = apiService.fetchMovieActors(movieId: movieId)
            async let directorsTask = apiService.fetchMovieDirectors(movieId: movieId)
            
            movieActors = try await actorsTask
            movieDirectors = try await directorsTask
        } catch {
            print("Failed to load actors/directors: \(error)")
        }
    }
    
    // MARK: - Load User Data
    private func loadUserData(signedInEmail: String, movieId: String) async {
        do {
            let result = try await apiService.fetchProfileByEmail(email: signedInEmail)
            currentUserId = result.user.id
            
            await loadReviews(movieId: movieId)
            await checkBookmarkStatus(movieId: movieId)
        } catch {
            print("Failed to load user: \(error)")
        }
    }
    
    // MARK: - Load Reviews
    func loadReviews(movieId: String) async {
        do {
            reviews = try await apiService.fetchMovieReviews(movieId: movieId)
        } catch {
            print("Failed to load reviews: \(error)")
        }
    }
    
    // MARK: - Check Bookmark Status
    func checkBookmarkStatus(movieId: String) async {
        guard !currentUserId.isEmpty else { return }
        do {
            savedMovieRecordId = try await apiService.checkIfMovieSaved(userId: currentUserId, movieId: movieId)
            isBookmarked = savedMovieRecordId != nil
        } catch {
            print("Failed to check bookmark: \(error)")
        }
    }
    
    // MARK: - Toggle Bookmark
    func toggleBookmark(movieId: String) async {
        guard !currentUserId.isEmpty else {
            print("No user ID - cannot save movie")
            return
        }
        
        do {
            if isBookmarked, let savedId = savedMovieRecordId {
                try await apiService.unsaveMovie(savedMovieId: savedId)
                isBookmarked = false
                savedMovieRecordId = nil
            } else {
                let newSavedId = try await apiService.saveMovie(userId: currentUserId, movieId: movieId)
                isBookmarked = true
                savedMovieRecordId = newSavedId
            }
        } catch {
            print("Failed to toggle bookmark: \(error)")
        }
    }
    
    // MARK: - Format Date
    func formatDate(_ isoDate: String) -> String {
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
