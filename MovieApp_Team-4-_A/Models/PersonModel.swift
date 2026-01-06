
import Foundation

struct PersonResponse: Codable, Sendable {
    let records: [PersonRecord]
}

struct PersonRecord: Codable, Identifiable, Sendable {
    let id: String
    let fields: PersonFields
}

struct PersonFields: Codable, Sendable { 
    let name: String
    let image: String?
}
