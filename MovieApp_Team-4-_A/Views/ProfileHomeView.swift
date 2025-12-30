//
//  ProfileHomeView.swift
//  Movies
//
//  Created by Rana Alngashy on 04/07/1447 AH.
//
import SwiftUI
import Combine
import PhotosUI

// 1. DATA MODEL
struct UserProfile {
    var firstName: String
    var lastName: String
    var email: String
    var profileImage: String = "avatar"
}

// 2. VIEW MODEL
class ProfileViewModel: ObservableObject {
    @Published var user = UserProfile(
        firstName: "Sarah",
        lastName: "Abdullah",
        email: "Xxxx234@gmail.com"
    )
    
    func saveChanges(first: String, last: String) {
        user.firstName = first
        user.lastName = last
    }
}

// 3. MAIN PROFILE VIEW
struct ProfileHomeView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // 🔙 Back Button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                }
                Spacer()
            }
            .padding(.bottom, 5)

            Text("Profile")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            NavigationLink(destination: ProfileInfoView(viewModel: viewModel)) {
                HStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading) {
                        Text("\(viewModel.user.firstName) \(viewModel.user.lastName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(viewModel.user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(white: 0.12))
                .cornerRadius(12)
            }

            Text("Saved movies")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)

            Spacer()

            VStack(spacing: 15) {
                Image(systemName: "video.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(white: 0.2))

                Text("No saved movies yet, start save your favourites")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 50)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// 4. DETAIL & EDIT VIEW
struct ProfileInfoView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var editFirst: String = ""
    @State private var editLast: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                }
                
                Spacer()
                
                Text(isEditing ? "Edit profile" : "Profile info")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if isEditing {
                        viewModel.saveChanges(first: editFirst, last: editLast)
                    } else {
                        editFirst = viewModel.user.firstName
                        editLast = viewModel.user.lastName
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.2))
                }
            }
            .padding()
            .background(Color.black)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            ScrollView {
                VStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                            
                            if isEditing {
                                Circle()
                                    .fill(Color.black.opacity(0.4))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .disabled(!isEditing)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    VStack(spacing: 0) {
                        InfoField(label: "First name", value: isEditing ? $editFirst : .constant(viewModel.user.firstName), isEditing: isEditing)
                        Divider().background(Color.white.opacity(0.1)).padding(.leading)
                        InfoField(label: "Last name", value: isEditing ? $editLast : .constant(viewModel.user.lastName), isEditing: isEditing)
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
                    .padding()
                }
            }

            Spacer()
            
            if !isEditing {
                Button(action: { }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.12))
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// 5. HELPER COMPONENT
struct InfoField: View {
    let label: String
    @Binding var value: String
    let isEditing: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Text(label)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)
            
            if isEditing {
                TextField("", text: $value)
                    .foregroundColor(.white)
                    .tint(.yellow)
                    .autocorrectionDisabled()
            } else {
                Text(value)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .frame(height: 55)
    }
}
#Preview {
    NavigationStack {
        ProfileHomeView()
    }
}
