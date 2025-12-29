//
//  MovieHorizontalRow.swift
//  Movies
//
//  Created by Rana Alngashy on 08/07/1447 AH.
//
import SwiftUI
struct MovieHorizontalRow: View {
    let title: String
    let movies: [MovieRecord]
    var isLarge: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: Title and Show More alignment
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !isLarge {
                    Button("Show more") {}
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(.gold1))
                }
            }
            .padding(.horizontal)

            if isLarge {
                // The dots count is automatic based on movies.count
                TabView {
                    ForEach(movies) { movie in
                        MovieCard(movie: movie, isLarge: true)
                    }
                }
                .frame(height: 460) // Enough space for image + dots
                .tabViewStyle(.page(indexDisplayMode: .always))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movies) { movie in
                            MovieCard(movie: movie, isLarge: false)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
