//
//  ActorModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 05/01/2026.
//

import Foundation

// MARK: - Actors Response
struct ActorsResponse: Codable {
    let records: [ActorRecord]
}

// MARK: - Actor Response (for single actor fetch)
struct ActorResponse: Codable {
    let records: [ActorRecord]
}

// MARK: - Actor Record
struct ActorRecord: Codable, Identifiable {
    let id: String
    let createdTime: String?
    let fields: ActorFields
}

// MARK: - Actor Fields
struct ActorFields: Codable {
    let name: String
    let image: String?
}
