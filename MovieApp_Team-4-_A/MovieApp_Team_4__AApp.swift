import SwiftUI

@main
struct MovieApp_Team_4__AApp: App {

    @State private var isAuthenticated = false
    @State private var signedInEmail = ""

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MoviesCenterView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
            } else {
                SignInView(
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
            }
        }
    }
}
