import SwiftUI

struct WriteReviewView: View {
    @Environment(\.dismiss) var dismiss
    let movieId: String
    let userId: String

    @State private var reviewText: String = ""
    @State private var rating: Int = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    let brandGold = Color(red: 0.9, green: 0.7, blue: 0.2)
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

                if isSubmitting {
                    ProgressView()
                        .tint(brandGold)
                } else {
                    Button {
                        submitReview()
                    } label: {
                        Text("Add")
                            .foregroundColor(brandGold)
                    }
                    .disabled(rating == 0 || reviewText.isEmpty) // Prevent empty reviews
                    .opacity((rating == 0 || reviewText.isEmpty) ? 0.5 : 1.0)
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
        //  Alert to show you the error if it fails
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        Task {
            do {
                print("📝 Submitting Review - Movie: \(movieId), User: \(userId)")
                
                let airtableRating = rating * 2
                
                let _ = try await apiService.postReview(
                    movieId: movieId,
                    userId: userId,
                    text: reviewText,
                    rating: airtableRating
                )
                
                print("✅ Review posted successfully!")
                isSubmitting = false
                dismiss()
                
            } catch {
                print("❌ Failed to post review: \(error)")
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isSubmitting = false
            }
        }
    }
}


