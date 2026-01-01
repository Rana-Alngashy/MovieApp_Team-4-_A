//
//  ProfileViewModel..swift
//  MovieApp_Team-4-_A
//
//  Created by Reema Alkhelaiwi on 31/12/2025.
//
import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var profileImage: String = ""
    @Published var savedMovies: [MovieRecord] = []
    @Published var isLoading = false

    private let apiService = APIService()

    func loadProfile(email: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await apiService.fetchProfileByEmail(email: email)

            self.name = result.user.fields.name ?? ""
            self.email = result.user.fields.email
            self.profileImage = result.user.fields.profileImage ?? ""
            self.savedMovies = result.savedMovies

        } catch {
            print("❌ Profile load error:", error)
        }
    }
}
