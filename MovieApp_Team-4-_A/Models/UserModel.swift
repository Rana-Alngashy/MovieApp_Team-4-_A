import Foundation

struct UserResponse: Codable, Sendable {
    let records: [UserRecord]
}

struct UserRecord: Codable, Identifiable, Sendable {
    let id: String
    let fields: UserFields
}

struct UserFields: Codable, Sendable {
    let name: String?
    let email: String
    let password: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case name, email, password
        case profileImage = "profile_image"
    }
}
