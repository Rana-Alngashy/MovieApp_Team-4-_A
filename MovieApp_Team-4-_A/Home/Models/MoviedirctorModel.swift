//
//  MoviedirctorModel.swift
//  MovieApp_Team-4-_A
//
//  Created by Danyah ALbarqawi on 05/01/2026.
//

import Foundation

// MARK: - Response Wrapper
struct MovieDirectorsResponse: Decodable {
    let records: [MovieDirectorRecord]
}

// MARK: - Record
struct MovieDirectorRecord: Decodable, Identifiable {
    let id: String
    let createdTime: String
    let fields: MovieDirectorFields
}

// MARK: - Fields
struct MovieDirectorFields: Decodable {
    let movie_id: String
    let director_id: String
}
