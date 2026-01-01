import SwiftUI

struct SignInView: View {
    @Binding var isAuthenticated: Bool // Connected to App state
    @Binding var signedInEmail: String // ✅ add this (keep the email for profile)

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var emailInvalid = false
    @State private var passwordInvalid = false

    @FocusState private var focusedField: Field?
    enum Field { case email, password }

    var isFormValid: Bool {
        !emailInvalid && !passwordInvalid && !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Background safety
            
            // Your Background Assets
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

                Text("Email")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color("gray1"))

                TextField("", text: $email, prompt: Text("Enter your Email").foregroundStyle(Color("gray1").opacity(0.55)))
                    .focused($focusedField, equals: .email)
                    .padding(14)
                    .background(Color("gray2").opacity(0.26))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(emailInvalid ? Color.red : (focusedField == .email ? Color("gold1") : Color.clear), lineWidth: 2.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.none)

                Text("Password")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color("gray1"))

                HStack {
                    if showPassword {
                        TextField("", text: $password, prompt: Text("Enter your Password").foregroundStyle(Color("gray1").opacity(0.55)))
                    } else {
                        SecureField("", text: $password, prompt: Text("Enter your Password").foregroundStyle(Color("gray1").opacity(0.55)))
                    }
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye").foregroundStyle(.gray)
                    }
                }
                .focused($focusedField, equals: .password)
                .padding(14)
                .background(Color("gray2").opacity(0.26))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(passwordInvalid ? Color.red : (focusedField == .password ? Color("gold1") : Color.clear), lineWidth: 2.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)

                Button {
                    validateFields()
                } label: {
                    Text("Sign in")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color("gold1") : Color("gray1"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 10)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .offset(y: 170)
        }
    }

    func validateFields() {
        emailInvalid = !email.contains("@") || !email.contains(".")
        passwordInvalid = password.count < 8

        if !emailInvalid && !passwordInvalid {
            withAnimation {
                signedInEmail = email
                isAuthenticated = true
            }
        }
    }
}

#Preview {
    SignInView(isAuthenticated: .constant(false), signedInEmail: .constant(""))
}
