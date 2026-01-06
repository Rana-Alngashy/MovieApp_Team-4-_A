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
        // task modifier
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
    // search bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            
            ZStack(alignment: .leading) {
                
               
                if viewModel.searchText.isEmpty {
                    Text("Search for Movie name, actors...")
                        .foregroundColor(.white.opacity(0.6))
                }
                
               
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
                .frame(width: UIScreen.main.bounds.width - 32, height: 200) 
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
