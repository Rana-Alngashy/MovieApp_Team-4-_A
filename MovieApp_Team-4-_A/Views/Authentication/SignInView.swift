import SwiftUI

struct SignInView: View {

    // MARK: - App State
    @Binding var isAuthenticated: Bool
    @Binding var signedInEmail: String

    // MARK: - UI State
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var emailInvalid = false
    @State private var passwordInvalid = false
    @State private var keyboardOffset: CGFloat = 0
    @State private var loginError: String?
    @State private var isLoading = false

    private let apiService = APIService()

    @FocusState private var focusedField: Field?
    enum Field { case email, password }

    var isFormValid: Bool {
        !emailInvalid && !passwordInvalid &&
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("signinbackground")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .offset(y: -50)

            Image("layersignin")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 17) {
                Spacer()

                Text("Sign in")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)

                Text("You'll find what you're looking for in the ocean of movies")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)

                // MARK: - Email
                Text("Email")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color("gray1"))

                TextField(
                    "",
                    text: $email,
                    prompt: Text("Enter your Email")
                        .foregroundStyle(Color("gray1").opacity(0.55))
                )
                .focused($focusedField, equals: .email)
                .padding(14)
                .background(Color("gray2").opacity(0.26))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            emailInvalid ? .red :
                            (focusedField == .email ? Color("gold1") : .clear),
                            lineWidth: 2.5
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)

                // MARK: - Password
                Text("Password")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color("gray1"))

                HStack {
                    if showPassword {
                        TextField(
                            "",
                            text: $password,
                            prompt: Text("Enter your Password")
                                .foregroundStyle(Color("gray1").opacity(0.55))
                        )
                    } else {
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("Enter your Password")
                                .foregroundStyle(Color("gray1").opacity(0.55))
                        )
                    }

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.gray)
                    }
                }
                .focused($focusedField, equals: .password)
                .padding(14)
                .background(Color("gray2").opacity(0.26))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            passwordInvalid ? .red :
                            (focusedField == .password ? Color("gold1") : .clear),
                            lineWidth: 2.5
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)

                // MARK: - SIGN IN BUTTON (API ONLY)
                Button {
                    validateFields()
                    guard isFormValid else { return }

                    Task {
                        isLoading = true
                        loginError = nil
                        defer { isLoading = false }

                        do {
                            let user = try await apiService.signInExistingUser(
                                email: email,
                               password: password
                            )

                            signedInEmail = user.fields.email
                            isAuthenticated = true

                        } catch {
                            loginError = "Invalid email or password"
                            isAuthenticated = false
                        }
                    }

                } label: {
                    Text(isLoading ? "Signing in..." : "Sign in")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color("gold1") : Color("gray1"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 10)
                .disabled(isLoading)

                // MARK: - Error Message
                if let loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .offset(y: 170 - keyboardOffset)
            .animation(.easeOut(duration: 0.25), value: keyboardOffset)
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardOffset = frame.height * 0.4
                }
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardOffset = 0
            }
        }
    }

    // MARK: - Validation ONLY (NO LOGIN HERE)
    func validateFields() {
        emailInvalid = !email.contains("@") || !email.contains(".")
        passwordInvalid = password.count < 8
    }
}

#Preview {
    SignInView(
        isAuthenticated: .constant(false),
        signedInEmail: .constant("")
    )
}
