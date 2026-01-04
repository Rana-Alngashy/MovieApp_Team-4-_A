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

struct MovieRecord: Codable, Identifiable, Hashable {
    let id: String
    let fields: MovieFields
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieRecord, rhs: MovieRecord) -> Bool {
        lhs.id == rhs.id
    }
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
struct UserResponse: Codable { let records: [UserRecord] }

struct UserRecord: Codable, Identifiable {
    let id: String
    let fields: UserFields
}

struct UserFields: Codable {
    let name: String?
    let email: String
    let password: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case name, email, password
        case profileImage = "profile_image"
    }
}

struct SavedMoviesResponse: Codable { let records: [SavedMovieRecord] }

struct SavedMovieRecord: Codable, Identifiable {
    let id: String
    let fields: SavedMovieFields
}

struct SavedMovieFields: Codable {
    let userID: String
    let movieID: [String]
    
    

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case movieID = "movie_id"
    }
}
