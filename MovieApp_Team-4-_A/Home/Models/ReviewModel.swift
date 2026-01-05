//
//  ReviewModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 01/01/2026.
//

import Foundation

// MARK: - Review Response
struct ReviewResponse: Codable {
    let records: [ReviewRecord]
}

// MARK: - Review Record
struct ReviewRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: ReviewFields
}

// MARK: - Review Fields
struct ReviewFields: Codable {
    let reviewText: String?
    let rate: Double?  // ⭐️ FIXED: Changed from Int to Double
    let movieId: String?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case reviewText = "review_text"
        case rate
        case movieId = "movie_id"
        case userId = "user_id"
    }
}
