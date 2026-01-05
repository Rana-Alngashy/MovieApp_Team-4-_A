//
//  WriteReviewView.swift
//  Movies
//
//  Created by Rana Alngashy on 04/07/1447 AH.
//
import SwiftUI

struct WriteReviewView: View {
    @Environment(\.dismiss) var dismiss

    // ✅ REQUIRED to post review
    let movieId: String
    let userId: String

    @State private var reviewText: String = ""
    @State private var rating: Int = 0

    // Brand color
    let brandGold = Color(red: 0.9, green: 0.7, blue: 0.2)

    // ✅ API
    private let apiService = APIService()

    var body: some View {
        VStack(spacing: 0) {

            // --- HEADER ---
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(brandGold)
                }

                Spacer()

                Text("Write a review")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // ✅ ADD REVIEW BUTTON (FIXED)
                Button {
                    Task {
                        do {
                            try await apiService.postReview(
                                movieId: movieId,
                                userId: userId,
                                text: reviewText,
                                rating: rating * 2 // ⭐️ 1–5 UI → 1–10 Airtable
                            )
                            dismiss()
                        } catch {
                            print("❌ Failed to post review:", error)
                        }
                    }
                } label: {
                    Text("Add")
                        .foregroundColor(brandGold)
                }
            }
            .padding()
            .background(Color.black)

            Divider()
                .background(Color.white.opacity(0.3))

            // --- CONTENT ---
            VStack(alignment: .leading, spacing: 20) {
                Text("Review")
                    .foregroundColor(.white)
                    .font(.headline)

                ZStack(alignment: .topLeading) {
                    if reviewText.isEmpty {
                        Text("Enter your review")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $reviewText)
                        .padding(8)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color(white: 0.12))
                        .cornerRadius(12)
                        .frame(height: 180)
                }

                // --- RATING ---
                HStack {
                    Text("Rating")
                        .foregroundColor(.white)
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .foregroundColor(brandGold)
                                .font(.title3)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
