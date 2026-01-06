import SwiftUI
@main
struct MovieApp: App {

    @State private var isAuthenticated = false
    @State private var signedInEmail = ""
    @StateObject private var profileVM = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MoviesCenterView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
                .environmentObject(profileVM)
            } else {
                SignInView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
                .environmentObject(profileVM)
            }
        }
    }
}
