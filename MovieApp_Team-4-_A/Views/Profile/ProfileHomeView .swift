import SwiftUI
import PhotosUI

// ✅ Profile Home (with working Sign Out)
struct ProfileHomeView: View {

    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Back button
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("gold1"))
                }
                Spacer()
            }

            // Profile title
            Text("Profile")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            // User card (opens edit screen)
            NavigationLink(
                destination: ProfileInfoView(
                    vm: vm,
                    isAuthenticated: $isAuthenticated,
                    signedInEmail: $signedInEmail
                )
            ) {
                HStack(spacing: 15) {
                    AsyncImage(url: URL(string: vm.profileImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(vm.name.isEmpty ? "Loading..." : vm.name)
                            .foregroundColor(.white)
                            .font(.headline)

                        Text(vm.email)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(white: 0.12))
                .cornerRadius(12)
            }

            // Saved movies
            Text("Saved movies")
                .font(.title2.bold())
                .foregroundColor(.white)

            if vm.isLoading {
                ProgressView().tint(.white)
                Spacer()
            } else if vm.savedMovies.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No saved movies yet")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.savedMovies) { movie in
                            Text(movie.fields.name)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(white: 0.12))
                                .cornerRadius(12)
                        }
                    }
                }
            }

            Spacer()

            // ✅ Sign Out
            Button(role: .destructive) {
                isAuthenticated = false
                signedInEmail = ""
            } label: {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await vm.loadProfile(email: signedInEmail)
        }
    }
}

// ✅ Edit Profile screen (Name + Email editable)
struct ProfileInfoView: View {

    @ObservedObject var vm: ProfileViewModel
    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false
    @State private var editName: String = ""
    @State private var editEmail: String = ""

    // ✅ ADDED: email validation error
    @State private var emailError: String?

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("gold1"))
                }

                Spacer()

                Text(isEditing ? "Edit profile" : "Profile info")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    if isEditing {

                        let trimmedEmail = editEmail
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        // ✅ EMAIL RULES (@ and .com)
                        guard trimmedEmail.contains("@"),
                              trimmedEmail.contains(".com") else {
                            emailError = "Email must contain @ and .com"
                            return
                        }

                        emailError = nil

                        Task {
                            await vm.saveProfileEdits(
                                name: editName,
                                email: trimmedEmail
                            )

                            vm.name = editName
                            vm.email = trimmedEmail
                            signedInEmail = trimmedEmail

                            isEditing = false
                            dismiss()
                        }

                    } else {
                        editName = vm.name
                        editEmail = vm.email
                        emailError = nil
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(Color("gold1"))
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
                            } else if let url = URL(string: vm.profileImage),
                                      !vm.profileImage.isEmpty {
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
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
                                    .foregroundColor(Color("gold1"))
                            }
                        }
                    }
                    .disabled(!isEditing)
                    .padding(.top, 40)
                    .padding(.bottom, 30)

                    VStack(spacing: 0) {
                        InfoField(
                            label: "Name",
                            value: isEditing ? $editName : .constant(vm.name),
                            isEditing: isEditing
                        )

                        Divider().background(Color.white.opacity(0.1))
                            .padding(.leading)

                        InfoField(
                            label: "Email",
                            value: isEditing ? $editEmail : .constant(vm.email),
                            isEditing: isEditing
                        )

                        // ✅ EMAIL ERROR MESSAGE
                        if let emailError {
                            Text(emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.leading)
                        }
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
                    .padding()
                }
            }

            Spacer()

            if !isEditing {
                Button(role: .destructive) {
                    isAuthenticated = false
                    signedInEmail = ""
                } label: {
                    Text("Sign Out")
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
        .onAppear {
            editName = vm.name
            editEmail = vm.email
        }
    }
}

// Helper component
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
                    .tint(Color("gold1"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
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
        ProfileHomeView(
            isAuthenticated: .constant(true),
            signedInEmail: .constant("Noora@gmail.com")
        )
        .environmentObject(ProfileViewModel())
    }
}
