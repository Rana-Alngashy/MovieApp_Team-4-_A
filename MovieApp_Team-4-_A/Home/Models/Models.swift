//
//  Models.swift
//  Movies
//
//  Created by Rana Alngashy on 08/07/1447 AH.
//

import Foundation

// MARK: - API Response
struct MovieResponse: Codable {
    let records: [MovieRecord]
}

// MARK: - Movie Record
struct MovieRecord: Codable, Identifiable {
    let id: String
    let fields: MovieFields
}

// MARK: - Movie Fields (MATCHES AIRTABLE JSON)
struct MovieFields: Codable {
    let name: String
    let poster: String
    let story: String
    let runtime: String
    let genre: [String]
    let rating: String
    let imdbRating: Double
    let language: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case poster
        case story
        case runtime
        case genre
        case rating
        case imdbRating = "IMDb_rating"
        case language
    }
}
