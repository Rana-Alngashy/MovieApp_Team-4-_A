
import Foundation

struct MovieResponse: Codable, Sendable { // Added Sendable
    let records: [MovieRecord]
}

struct MovieRecord: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let fields: MovieFields
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieRecord, rhs: MovieRecord) -> Bool {
        lhs.id == rhs.id
    }
}

struct MovieFields: Codable, Sendable {
    let name: String
    let poster: String
    let story: String
    let runtime: String
    let genre: [String]
    let rating: String
    let imdbRating: Double
    let language: [String]
    let actors: [String]?

    enum CodingKeys: String, CodingKey {
        case name, poster, story, runtime, genre, rating, language, actors
        case imdbRating = "IMDb_rating"
    }
}

struct SavedMoviesResponse: Codable, Sendable {
    let records: [SavedMovieRecord]
}

struct SavedMovieRecord: Codable, Identifiable, Sendable {
    let id: String
    let fields: SavedMovieFields
}

struct SavedMovieFields: Codable, Sendable { 
    let userID: String
    let movieID: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case movieID = "movie_id"
    }
}
