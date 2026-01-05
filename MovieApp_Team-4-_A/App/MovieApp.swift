import SwiftUI

@main
struct MovieApp: App {

    @State private var isAuthenticated = false
    @State private var signedInEmail = ""

    // ⭐️ ADD THIS
    @StateObject private var profileVM = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MoviesCenterView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
                // ⭐️ INJECT HERE
                .environmentObject(profileVM)
            } else {
                SignInView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
                // ⭐️ INJECT HERE TOO (important)
                .environmentObject(profileVM)
            }
        }
    }
}
