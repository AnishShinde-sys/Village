// SignInView.swift

import SwiftUI
import FirebaseAuth
import Firebase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Village - Sign In")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    signIn()
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding()
        }
    }

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter your email and password."
            self.showError = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
            } else {
                session.listen()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
