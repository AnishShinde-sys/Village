import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseMessaging

struct SignInSignUpView: View {
    @State private var isSignIn = true
    @State private var isParent = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Village")
                    .font(.largeTitle)
                    .bold()

                Picker(selection: $isSignIn, label: Text("Login or Register")) {
                    Text("Sign In").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if !isSignIn {
                    Picker("Role", selection: $isParent) {
                        Text("Kid").tag(false)
                        Text("Parent").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    isSignIn ? signIn() : signUp()
                }) {
                    Text(isSignIn ? "Sign In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(isSignIn ? Color.green : Color.blue)
                        .cornerRadius(15.0)
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle(isSignIn ? "Sign In" : "Sign Up")
        }
    }

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter your email and password."
            self.showError = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
            } else {
                self.showError = false
                self.errorMessage = ""
                session.listen()
            }
        }
    }

    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            self.errorMessage = "Please fill in all required fields."
            self.showError = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("SignUp: Error creating user: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.showError = true
                return
            }

            guard let user = authResult?.user else {
                print("SignUp: No auth result user")
                self.errorMessage = "Unexpected error occurred."
                self.showError = true
                return
            }

            print("SignUp: User created successfully with ID: \(user.uid)")
            let db = Firestore.firestore()
            var data: [String: Any] = [
                "email": self.email,
                "name": self.name,
                "isParent": self.isParent,
                "uid": user.uid
            ]

            if isParent {
                let villageID = UUID().uuidString
                data["villageID"] = villageID
                print("SignUp: Creating village with ID: \(villageID)")

                // Create village document
                db.collection("villages").document(villageID).setData([
                    "villageID": villageID,
                    "name": "\(self.name)'s Village"
                ]) { err in
                    if let err = err {
                        print("SignUp: Error creating village: \(err.localizedDescription)")
                        self.errorMessage = err.localizedDescription
                        self.showError = true
                        return
                    }

                    print("SignUp: Village created successfully")
                    // Add parent to village's parents subcollection
                    db.collection("villages").document(villageID).collection("parents").document(user.uid).setData([
                        "uid": user.uid,
                        "name": self.name,
                        "email": self.email,
                        "fcmToken": Messaging.messaging().fcmToken ?? ""
                    ]) { err in
                        if let err = err {
                            print("SignUp: Error adding parent to village: \(err.localizedDescription)")
                            self.errorMessage = err.localizedDescription
                            self.showError = true
                            return
                        }
                        print("SignUp: Parent added to village")
                        self.createUserDocument(db: db, user: user, data: data)
                    }
                }
            } else {
                print("SignUp: Creating kid user document")
                self.createUserDocument(db: db, user: user, data: data)
            }
        }
    }

    private func createUserDocument(db: Firestore, user: User, data: [String: Any]) {
        print("SignUp: Creating user document with data: \(data)")
        db.collection("users").document(user.uid).setData(data) { err in
            if let err = err {
                print("SignUp: Error creating user document: \(err.localizedDescription)")
                self.errorMessage = err.localizedDescription
                self.showError = true
                return
            }

            print("SignUp: User document created successfully")
            DispatchQueue.main.async {
                // Update session data directly
                self.session.user = user
                self.session.isSignedIn = true
                self.session.isUserDataLoaded = true
                self.session.userData = data

                // Handle 'isParent' being stored as Bool, Int, or String
                if let isParentValue = data["isParent"] as? Bool {
                    self.session.isParent = isParentValue
                } else if let isParentInt = data["isParent"] as? Int {
                    self.session.isParent = isParentInt != 0
                } else if let isParentString = data["isParent"] as? String {
                    self.session.isParent = (isParentString == "true")
                } else {
                    self.session.isParent = false
                }

                self.session.villageID = data["villageID"] as? String
                print("SignUp: Session data updated - isParent: \(self.session.isParent), villageID: \(self.session.villageID ?? "nil")")
                self.session.saveFCMToken()
            }
        }
    }
}

