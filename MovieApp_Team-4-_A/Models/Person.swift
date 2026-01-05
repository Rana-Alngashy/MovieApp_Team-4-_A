
import Foundation

struct PersonResponse: Codable, Sendable { // Added Sendable
    let records: [PersonRecord]
}

struct PersonRecord: Codable, Identifiable, Sendable { // Added Sendable
    let id: String
    let fields: PersonFields
}

struct PersonFields: Codable, Sendable { // Added Sendable
    let name: String
    let image: String?
}
