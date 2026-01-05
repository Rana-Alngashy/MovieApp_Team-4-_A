//
//  DircoterModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 05/01/2026.
//

import Foundation

// MARK: - Directors Response Wrapper
struct DirectorsResponse: Codable {
    let records: [DirectorRecord]
}

// MARK: - Director Response (for single director fetch)
struct DirectorResponse: Codable {
    let records: [DirectorRecord]
}

// MARK: - Director Record
struct DirectorRecord: Codable, Identifiable {
    let id: String
    let createdTime: String?
    let fields: DirectorFields
}

// MARK: - Director Fields
struct DirectorFields: Codable {
    let name: String
    let image: String?
}
