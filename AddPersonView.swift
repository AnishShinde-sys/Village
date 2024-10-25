//AddPersonView.swift


import SwiftUI
import Firebase


struct AddPersonView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var session: SessionStore
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var showError = false


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email of the person to add", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()


                Button(action: {
                    addPerson()
                }) {
                    Text("Add Person")
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
                        .padding(.horizontal)
                }


                Spacer()
            }
            .navigationTitle("Add Person")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }


    func addPerson() {
        guard let villageID = session.villageID else { return }
        let db = Firestore.firestore()


        // Fetch user by email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Error finding user: \(error.localizedDescription)"
                self.showError = true
                return
            }


            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.errorMessage = "No user found with that email."
                self.showError = true
                return
            }


            let userData = documents[0].data()
            let uid = userData["uid"] as? String ?? ""
            let name = userData["name"] as? String ?? "Unknown"
            let isParent = userData["isParent"] as? Bool ?? false
            let fcmToken = userData["fcmToken"] as? String ?? ""


            if isParent {
                // Add parent to village's parents collection
                db.collection("villages").document(villageID).collection("parents").document(uid).setData([
                    "uid": uid,
                    "name": name,
                    "email": email,
                    "fcmToken": fcmToken
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Error adding parent: \(error.localizedDescription)"
                        self.showError = true
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                // Add kid to village's kids collection
                db.collection("villages").document(villageID).collection("kids").document(uid).setData([
                    "uid": uid,
                    "name": name,
                    "email": email,
                    "fcmToken": fcmToken
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Error adding kid: \(error.localizedDescription)"
                        self.showError = true
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }


            // Update user's villageID
            db.collection("users").document(uid).updateData([
                "villageID": villageID
            ]) { error in
                if let error = error {
                    print("Error updating user's villageID: \(error.localizedDescription)")
                } else {
                    print("User's villageID updated.")
                }
            }
        }
    }
}
