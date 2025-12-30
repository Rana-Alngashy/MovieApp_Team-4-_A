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
        if isLarge {
            // ⭐️ GOAL UI: HIGH RATED CARD
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 420)
                .cornerRadius(12)
                .clipped()

                // Overlay Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.fields.name)
                        .font(.system(size: 38, weight: .bold)) // Large Bold Title
                        .foregroundColor(.white)
                    
                    // Star Rating (Smaller Stars)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                                .font(.system(size: 10))
                                .foregroundColor(Color(.gold1))
                        }
                    }
                    
                    // Corrected Rating Math
                    HStack(spacing: 5) {
                        Text(String(format: "%.1f", movie.fields.imdbRating / 2)) // Divide by 2
                            .font(.system(size: 20, weight: .bold))
                        Text("out of 5")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .foregroundColor(.white)

                    Text("\(movie.fields.genre.first ?? "") . \(movie.fields.runtime)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(20)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.9)]),
                                   startPoint: .top, endPoint: .bottom)
                    .cornerRadius(12)
                )
            }
        } else {
            // ⭐️ GOAL UI: VERTICAL POSTER CARD
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                // Strict vertical aspect ratio
                .frame(width: 175, height: 260)
                .cornerRadius(10)
                .clipped()
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
#Preview {
    MoviesCenterView()
}
