import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingError
    case unauthorized
    case serverError
    case cannotParse
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The server address is incorrect."
        case .requestFailed(let code): return "The request failed with status code: \(code)."
        case .decodingError: return "There was an issue processing data from the server."
        case .unauthorized: return "Your session has expired. Please sign in again."
        case .serverError: return "The server is currently having issues. Please try later."
        case .cannotParse: return "Failed to read the server response."
        case .unknown(let error): return error.localizedDescription
        }
    }
}
