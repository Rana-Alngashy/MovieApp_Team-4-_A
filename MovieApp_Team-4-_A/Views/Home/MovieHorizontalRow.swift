//
//  MovieHorizontalRow.swift
//  MovieApp_Team-4-_A
//
//  Created by Rana Alngashy on 16/07/1447 AH.
//
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
                    // ✅ Updated: Now uses NavigationLink instead of an empty Button
                    NavigationLink(value: title) {
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
