import SwiftUI
import PhotosUI

// MARK: - Saved Movie Card (Grid Style)
struct SavedMovieCard: View {
    let movie: MovieRecord
    
    var body: some View {
        AsyncImage(url: URL(string: movie.fields.poster)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(ProgressView().tint(.white))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(0.7, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            case .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(0.7, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct ProfileHomeView: View {

    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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

            Text("Profile")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            // User card
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

            Text("Saved movies")
                .font(.title2.bold())
                .foregroundColor(.white)

            if vm.isLoading {
                ProgressView().tint(.white)
            } else if vm.savedMovies.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No saved movies yet")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(vm.savedMovies) { movie in
                            // ✅ FIXED: Added NavigationLink to Movie Details
                            NavigationLink(destination: MoviesDetailsView(movie: movie, signedInEmail: signedInEmail)) {
                                SavedMovieCard(movie: movie)
                            }
                        }
                    }
                }
            }

            Spacer()

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

// MARK: - Profile Info View
struct ProfileInfoView: View {

    @ObservedObject var vm: ProfileViewModel
    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false
    @State private var editName = ""
    @State private var editEmail = ""
    @State private var emailError: String?

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    private let dummyImageURL =
    "https://i.pinimg.com/1200x/7e/fd/0f/7efd0f809a51439d0a75e7a8c414f0f5.jpg"

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Button { dismiss() } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("gold1"))
                }

                Spacer()

                Text(isEditing ? "Edit profile" : "Profile info")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button {
                    if isEditing {

                        let trimmedEmail =
                        editEmail.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard trimmedEmail.contains("@"),
                              trimmedEmail.contains(".com") else {
                            emailError = "Email must contain @ and .com"
                            return
                        }

                        emailError = nil

                        Task {
                            await vm.saveProfileImage(imageURL: dummyImageURL)
                            await vm.saveProfileEdits(
                                name: editName,
                                email: trimmedEmail
                            )

                            vm.profileImage = dummyImageURL
                            vm.name = editName
                            vm.email = trimmedEmail
                            signedInEmail = trimmedEmail

                            isEditing = false
                            dismiss()
                        }

                    } else {
                        editName = vm.name
                        editEmail = vm.email
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(Color("gold1"))
                }
            }
            .padding()
            .background(Color.black)

            Divider().background(Color.white.opacity(0.3))

            ScrollView {
                VStack {

                    // Profile Image
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            Group {
                                if let selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                } else {
                                    AsyncImage(url: URL(string: vm.profileImage)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())

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
                    .onChange(of: selectedItem) { newItem in
                        guard let newItem else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage   
                            }
                        }
                    }

                    .padding(.top, 40)
                    .padding(.bottom, 30)

                    VStack(spacing: 0) {
                        InfoField(
                            label: "Name",
                            value: isEditing ? $editName : .constant(vm.name),
                            isEditing: isEditing
                        )

                        Divider().background(Color.white.opacity(0.1))

                        InfoField(
                            label: "Email",
                            value: isEditing ? $editEmail : .constant(vm.email),
                            isEditing: isEditing
                        )

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

// MARK: - Helper Field
struct InfoField: View {
    let label: String
    @Binding var value: String
    let isEditing: Bool

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)

            if isEditing {
                TextField("", text: $value)
                    .foregroundColor(.white)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileHomeView(
            isAuthenticated: .constant(true),
            signedInEmail: .constant("Noora@gmail.com")
        )
        .environmentObject(ProfileViewModel())
    }
}
