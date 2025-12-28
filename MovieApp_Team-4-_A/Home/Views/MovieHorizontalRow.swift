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
    var isLarge: Bool = false   // ⭐️ NEW

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(movies) { movie in
                        MovieCard(movie: movie, isLarge: isLarge)
                            .frame(width: isLarge ? 200 : 150)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
