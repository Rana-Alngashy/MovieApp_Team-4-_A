import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published State
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var profileImage: String = ""
    @Published var savedMovies: [MovieRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil


    private(set) var userRecordID: String?
    private let apiService = APIService()

    // MARK: - Load Profile
    func loadProfile(email: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiService.fetchProfileByEmail(email: email)

            
            self.userRecordID = result.user.id
            self.name = result.user.fields.name ?? ""
            self.email = result.user.fields.email
            self.profileImage = result.user.fields.profileImage ?? ""
            self.savedMovies = result.savedMovies

        } catch let error as APIError {
            switch error {
            case .requestFailed(let statusCode):
                errorMessage = "Server error \(statusCode). Please try again later."
            case .serverError:
                errorMessage = "Server is unavailable. Please try again later."
            case .unauthorized:
                errorMessage = "Session expired. Please sign in again."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

    }

    // MARK: - SAVE PROFILE EDITS (THIS WAS MISSING)
    func saveProfileEdits(name: String, email: String) async {
        guard let recordID = userRecordID else {
            print("❌ Missing user record ID")
            return
        }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await apiService.updateUserProfile(
                recordID: recordID,
                name: cleanName,
                email: cleanEmail
            )
            self.name = cleanName
            self.email = cleanEmail

        } catch let error as APIError {
            switch error {
            case .requestFailed(let statusCode):
                errorMessage = "Server error \(statusCode). Please try again later."
            case .serverError:
                errorMessage = "Server is unavailable. Please try again later."
            case .unauthorized:
                errorMessage = "Session expired. Please sign in again."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

    }
    // MARK: - SAVE PROFILE IMAGE (URL only)
    func saveProfileImage(imageURL: String) async {
        guard let recordID = userRecordID else {
            print("❌ Missing user record ID")
            return
        }

        do {
            try await apiService.updateUserProfileImage(
                recordID: recordID,
                imageURL: imageURL
            )

            self.profileImage = imageURL

        } catch let error as APIError {
            switch error {
            case .requestFailed(let statusCode):
                errorMessage = "Server error \(statusCode). Please try again later."
            case .serverError:
                errorMessage = "Server is unavailable. Please try again later."
            case .unauthorized:
                errorMessage = "Session expired. Please sign in again."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

    }
}
