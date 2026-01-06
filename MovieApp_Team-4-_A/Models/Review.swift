import Foundation

enum AppRoute: Hashable {
    case writeReview(movieId: String, userId: String)
    case genre(String)
}

struct ReviewResponse: Codable, Sendable {
    let records: [ReviewRecord]
}

struct ReviewRecord: Codable, Identifiable, Sendable {
    let id: String
    let createdTime: String
    let fields: ReviewFields
}

struct ReviewFields: Codable, Sendable {
    let reviewText: String?
    let rate: Double?
    
    // ✅ FIXED: Changed back to String? based on your Postman file.
    // The error -1011 happened because we tried to use [String].
    let movieId: String?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case reviewText = "review_text"
        case rate
        case movieId = "movie_id"
        case userId = "user_id"
    }
}
