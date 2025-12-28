//
//  MovieViewModel.swift
//  Movies
//
//  Created by Rana Alngashy on 06/07/1447 AH.
//
import Foundation
import Combine
@MainActor
class MovieViewModel: ObservableObject {

    @Published var movies: [MovieRecord] = []
    @Published var searchText: String = ""
    @Published var isLoading = false

    private let apiService = APIService()

    var filteredMovies: [MovieRecord] {
        guard !searchText.isEmpty else { return movies }

        return movies.filter { movie in
            let titleMatch = movie.fields.name
                .localizedCaseInsensitiveContains(searchText)

            let genreMatch = movie.fields.genre.contains {
                $0.localizedCaseInsensitiveContains(searchText)
            }

            return titleMatch || genreMatch
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
