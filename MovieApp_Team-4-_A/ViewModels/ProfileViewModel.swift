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

        } catch {
            print("❌ Profile load error:", error)
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

        } catch {
            print("❌ Save profile error:", error.localizedDescription)
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

        } catch {
            print("❌ Failed to save profile image:", error.localizedDescription)
        }
    }
}
