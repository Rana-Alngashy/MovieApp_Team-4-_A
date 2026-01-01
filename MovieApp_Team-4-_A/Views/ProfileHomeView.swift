import SwiftUI

struct ProfileHomeView: View {

    @StateObject private var vm = ProfileViewModel()
    @Environment(\.dismiss) var dismiss

    let signedInEmail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Back button
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(.gold1))
                }
                Spacer()
            }

            // Profile title
            Text("Profile")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            // User card
            HStack(spacing: 15) {
                AsyncImage(url: URL(string: vm.profileImage)) { image in
                    image.resizable()
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
            }
            .padding()
            .background(Color(white: 0.12))
            .cornerRadius(12)

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
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await vm.loadProfile(email: signedInEmail)
        }
    }
}
#Preview {
    NavigationStack {
        ProfileHomeView(signedInEmail: "Noora@gmail.com")
    }
}
