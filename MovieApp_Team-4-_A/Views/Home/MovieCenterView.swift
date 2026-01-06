import SwiftUI

struct MoviesCenterView: View {

    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    @StateObject private var viewModel = MovieViewModel()
    @EnvironmentObject var profileVM: ProfileViewModel

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
                        
                        MovieHorizontalRow(
                            title: "Highly Rated",
                            movies: viewModel.highlyRatedMovies,
                            isLarge: true
                        )
                        
                        ForEach(viewModel.genres, id: \.self) { genre in
                            MovieHorizontalRow(
                                title: genre,
                                movies: viewModel.moviesByGenre[genre] ?? []
                            )
                        }
                    }
                }
            }
            .navigationDestination(for: MovieRecord.self) { movie in
                MoviesDetailsView(movie: movie, signedInEmail: signedInEmail)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                    
                case .writeReview(let movieId, let userId):
                    WriteReviewView(
                        movieId: movieId,
                        userId: userId
                    )
                    
                case .genre(let genre):
                    let genreMovies = viewModel.moviesByGenre[genre] ?? []
                    MovieGridView(title: genre, movies: genreMovies)
                }
            }
            
            
        }
        .task {
            await viewModel.loadMovies()
            
            if profileVM.email != signedInEmail {
                await profileVM.loadProfile(email: signedInEmail)
            }
        }
    }


    



private var header: some View {
        HStack {
            Text("Movies Center")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            NavigationLink {
                ProfileHomeView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
            } label: {
                if let url = URL(string: profileVM.profileImage),
                   !profileVM.profileImage.isEmpty {
                    
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            // ZStack allows us to layer a custom placeholder behind the TextField
            ZStack(alignment: .leading) {
                
                // 1. Show this custom Text only when the search field is empty
                if viewModel.searchText.isEmpty {
                    Text("Search for Movie name, actors...")
                        .foregroundColor(.white.opacity(0.6)) // 0.6 opacity looks best (distinct from typed text)
                }
                
                // 2. The actual TextField (Empty string "" for the title since we have a custom one)
                TextField("", text: $viewModel.searchText)
                    .foregroundColor(.white) // This makes the text YOU TYPE white
                    .autocorrectionDisabled()
            }
        }
        .padding(12)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MovieCard: View {
    let movie: MovieRecord
    var isLarge: Bool = false

    var body: some View {
        if isLarge {
            ZStack(alignment: .bottomLeading) {
                // 1. The Main Poster Image
                AsyncImage(url: URL(string: movie.fields.poster)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 420)
                .cornerRadius(12)
                .clipped()

                // 2. The Gradient Shade (Moved here to cover the full width)
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: UIScreen.main.bounds.width - 32, height: 200) // Adjust height as needed
                .cornerRadius(12)

                // 3. The Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.fields.name)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                                .font(.system(size: 10))
                                .foregroundColor(Color(.gold1))
                        }
                    }
                    HStack(spacing: 5) {
                                            Text(String(format: "%.1f", movie.fields.imdbRating / 2))
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
                                    .padding(20) // This padding now only affects text, not the shade
                                }
                            } else {
                                // ... (rest of small card code)
                                VStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: movie.fields.poster)) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 175, height: 260)
                                    .cornerRadius(10)
                                    .clipped()
                                }
                            }
                        }
                    }

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
struct MovieGridView: View {
    let title: String
    let movies: [MovieRecord]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(movies) { movie in
                    NavigationLink(value: movie) {
                        MovieCard(movie: movie, isLarge: false)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    MoviesCenterView(
        isAuthenticated: .constant(true),
        signedInEmail: .constant("Noora@gmail.com")
    )
}
