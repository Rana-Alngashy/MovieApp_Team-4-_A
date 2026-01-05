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

    // ✅ REQUIRED: store Airtable record ID
    private(set) var userRecordID: String?

    private let apiService = APIService()

    // MARK: - Load Profile
    func loadProfile(email: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiService.fetchProfileByEmail(email: email)

            // ✅ SAVE RECORD ID
            self.userRecordID = result.user.id

            // ✅ Update UI
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

            // ✅ Keep UI in sync after successful save
            self.name = cleanName
            self.email = cleanEmail

        } catch {
            print("❌ Save profile error:", error.localizedDescription)
        }
    }
}
