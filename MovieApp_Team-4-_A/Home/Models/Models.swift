//
//  Models.swift
//  Movies
//
//  Created by Rana Alngashy on 08/07/1447 AH.
//
import Foundation

struct MovieResponse: Codable {
    let records: [MovieRecord]
}

struct MovieRecord: Codable, Identifiable {
    let id: String
    let fields: MovieFields
}

struct MovieFields: Codable {
    let name: String
    let poster: String
    let story: String
    let runtime: String
    let genre: [String]
    let rating: String
    let imdbRating: Double
    let language: [String]
    let actors: [String]? // ⭐️ Added this field

    enum CodingKeys: String, CodingKey {
        case name, poster, story, runtime, genre, rating, language, actors
        case imdbRating = "IMDb_rating"
    }
}
