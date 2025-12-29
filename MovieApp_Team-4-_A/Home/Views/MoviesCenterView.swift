//
//  MoviesCenterView.swift
//  Movies
//
//  Created by Rana Alngashy on 06/07/1447 AH.
//
import SwiftUI

struct MoviesCenterView: View {

    @StateObject private var viewModel = MovieViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        header

                        searchBar

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding()
                        }

                        // Highly Rated Row
                        MovieHorizontalRow(
                            title: "Highly Rated",
                            movies: viewModel.highlyRatedMovies,
                            isLarge: true
                        )

                        // Genre Rows
                        ForEach(viewModel.genres, id: \.self) { genre in
                            MovieHorizontalRow(
                                title: genre,
                                movies: viewModel.moviesByGenre[genre] ?? []
                            )
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadMovies()
        }
    }

    private var header: some View {
        HStack {
            Text("Movies Center")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Spacer()

            NavigationLink {
                ProfileHomeView()
            } label: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search for Movie name, actors...",
                      text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// ⭐️ YOUR ORIGINAL MOVIE CARD RESTORED
struct MovieCard: View {
    let movie: MovieRecord
    var isLarge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: movie.fields.poster)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: isLarge ? 280 : 220)
            .cornerRadius(16)
            .clipped()

            Text(movie.fields.name)
                .foregroundColor(.white)
                .font(isLarge ? .title3.bold() : .headline)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)

                Text(String(format: "%.1f", movie.fields.imdbRating))
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
    }
}

// ⭐️ UPDATED EXTENSION TO ENABLE SEARCH
extension MovieViewModel {
    var highlyRatedMovies: [MovieRecord] {
        filteredMovies.filter { $0.fields.imdbRating >= 9.0 }
            .sorted { $0.fields.imdbRating > $1.fields.imdbRating }
    }

    var moviesByGenre: [String: [MovieRecord]] {
        Dictionary(grouping: filteredMovies.flatMap { movie in
            movie.fields.genre.map { ($0, movie) }
        }) { $0.0 }
        .mapValues { $0.map { $0.1 } }
    }

    var genres: [String] {
        moviesByGenre.keys.sorted()
    }
}
