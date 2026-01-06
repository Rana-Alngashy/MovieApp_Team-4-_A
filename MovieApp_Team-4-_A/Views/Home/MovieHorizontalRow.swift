import SwiftUI

struct MovieHorizontalRow: View {
    let title: String
    let movies: [MovieRecord]
    var isLarge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !isLarge {
                    
                    NavigationLink(value: AppRoute.genre(title)) {
                        Text("Show more")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(.gold1))
                    }
                }
            }
            .padding(.horizontal)

            if isLarge {
                TabView {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie) {
                            MovieCard(movie: movie, isLarge: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(height: 460)
                .tabViewStyle(.page(indexDisplayMode: .always))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie) {
                                MovieCard(movie: movie, isLarge: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
