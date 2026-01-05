//
//  MovieActorModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 05/01/2026.
//

import Foundation

// MARK: - Response Wrapper
struct MovieActorsResponse: Decodable {
    let records: [MovieActorRecord]
}

// MARK: - Record
struct MovieActorRecord: Decodable, Identifiable {
    let id: String
    let createdTime: String
    let fields: MovieActorFields
}

// MARK: - Fields
struct MovieActorFields: Decodable {
    let movie_id: String
    let actor_id: String
}
