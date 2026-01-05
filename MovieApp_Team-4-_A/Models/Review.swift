
import Foundation

struct ReviewResponse: Codable, Sendable { // Added Sendable
    let records: [ReviewRecord]
}

struct ReviewRecord: Codable, Identifiable, Sendable { // Added Sendable
    let id: String
    let createdTime: String
    let fields: ReviewFields
}

struct ReviewFields: Codable, Sendable { // Added Sendable
    let reviewText: String?
    let rate: Double?
    let movieId: String?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case reviewText = "review_text"
        case rate
        case movieId = "movie_id"
        case userId = "user_id"
    }
}
