//
//  WriteReviewView.swift
//  Movies
//
//  Created by Rana Alngashy on 04/07/1447 AH.
//

import SwiftUI

struct WriteReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reviewText: String = ""
    @State private var rating: Int = 0
    
    // Using the gold color consistent with your design
    let brandGold = Color(red: 0.9, green: 0.7, blue: 0.2)
    
    var body: some View {
        VStack(spacing: 0) {
            // --- CUSTOM HEADER (No Glass) ---
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
                
                Button(action: {
                    // Logic to add review to movie will go here tomorrow
                    print("Review Added: \(reviewText), Rating: \(rating)")
                    dismiss()
                }) {
                    Text("Add")
                        .foregroundColor(brandGold)
                }
            }
            .padding()
            .background(Color.black)
            
            // --- THE SMALL WHITE LINE ---
            Divider()
                .background(Color.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Review")
                    .foregroundColor(.white)
                    .font(.headline)
                
                // --- CUSTOM TEXT EDITOR ---
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
                        .scrollContentBackground(.hidden) // Required to show custom background
                        .background(Color(white: 0.12))
                        .cornerRadius(12)
                        .frame(height: 180)
                }
                
                // --- RATING SYSTEM ---
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
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
