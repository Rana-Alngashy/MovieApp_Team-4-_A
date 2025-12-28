//
//  MovieApp_Team_4__AApp.swift
//  MovieApp_Team-4-_A
//
//  Created by Rana Alngashy on 08/07/1447 AH.
//


import SwiftUI

@main
struct MovieApp_Team_4__AApp: App {
    // This state controls the root view of the entire app
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MoviesCenterView()
            } else {
                // Show the sign-in screen
                SignInView(isAuthenticated: $isAuthenticated)
                    .transition(.opacity)
            }
        }
    }
}
