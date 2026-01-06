import Foundation
import Combine
import SwiftUI

@MainActor
class MovieViewModel: ObservableObject {

    @Published var movies: [MovieRecord] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()

    // This is the core logic for search functionality
    var filteredMovies: [MovieRecord] {
        guard !searchText.isEmpty else { return movies }

        return movies.filter { movie in
            let titleMatch = movie.fields.name
                .localizedCaseInsensitiveContains(searchText)

            let genreMatch = movie.fields.genre.contains {
                $0.localizedCaseInsensitiveContains(searchText)
            }
            
            let actorMatch = movie.fields.actors?.contains {
                $0.localizedCaseInsensitiveContains(searchText)
            } ?? false

            return titleMatch || genreMatch || actorMatch
        }
    }

    func loadMovies() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            movies = try await apiService.fetchMovies()
        } catch let error as APIError {
            switch error {
            case .requestFailed(let statusCode):
                errorMessage = "Server error \(statusCode). Please try again later."
            case .serverError:
                errorMessage = "Server is unavailable. Please try again later."
            case .unauthorized:
                errorMessage = "Session expired. Please sign in again."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
