import Foundation
import Combine
import SwiftUI

@MainActor
class MovieViewModel: ObservableObject {

    @Published var movies: [MovieRecord] = []
    @Published var searchText: String = ""
    @Published var isLoading = false

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
        do {
            movies = try await apiService.fetchMovies()
        } catch {
            print("❌ Error:", error)
        }
        isLoading = false
    }
}
