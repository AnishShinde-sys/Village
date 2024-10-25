// SignUpView.swift

import SwiftUI
import FirebaseAuth
import Firebase

struct SignUpView: View {
    @State private var isParent = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var session: SessionStore
    @State private var showSignIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Village - Sign Up")
                    .font(.largeTitle)
                    .bold()

                Picker("Role", selection: $isParent) {
                    Text("Kid").tag(false)
                    Text("Parent").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    self.showSignIn = true
                }) {
                    Text("Already have an account? Sign In")
                        .font(.subheadline)
                }
                .sheet(isPresented: $showSignIn) {
                    SignInView()
                        .environmentObject(session)
                }

                Spacer()
            }
            .padding()
        }
    }

    func signUp() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please fill in all fields."
            self.showError = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
            } else if let user = authResult?.user {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "name": self.name,
                    "email": self.email,
                    "isParent": self.isParent,
                    "uid": user.uid
                ]) { err in
                    if let err = err {
                        self.errorMessage = err.localizedDescription
                        self.showError = true
                    } else {
                        session.listen()
                    }
                }
            }
        }
    }
}
