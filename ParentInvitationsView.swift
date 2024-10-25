// ParentInvitationsView.swift

import SwiftUI
import Firebase

struct ParentInvitationsView: View {
    @EnvironmentObject var session: SessionStore
    @State private var invitations: [ParentInvitation] = []
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        VStack {
            if invitations.isEmpty {
                Text("No invitations at this time.")
                    .padding()
            } else {
                List(invitations) { invitation in
                    VStack(alignment: .leading) {
                        Text("Invitation from \(invitation.senderName)")
                            .font(.headline)
                        Button(action: {
                            acceptInvitation(invitation: invitation)
                        }) {
                            Text("Accept")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchInvitations()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func fetchInvitations() {
        guard let userID = session.user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("invitations")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error fetching invitations: \(error.localizedDescription)"
                    self.showError = true
                    return
                }
                invitations = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let senderName = data["senderName"] as? String ?? "Unknown"
                    let villageID = data["villageID"] as? String ?? ""
                    return ParentInvitation(id: id, senderName: senderName, villageID: villageID)
                } ?? []
            }
    }

    func acceptInvitation(invitation: ParentInvitation) {
        guard let userID = session.user?.uid else { return }
        let db = Firestore.firestore()

        // Update user's villageID
        db.collection("users").document(userID).updateData([
            "villageID": invitation.villageID
        ]) { error in
            if let error = error {
                self.errorMessage = "Error accepting invitation: \(error.localizedDescription)"
                self.showError = true
                return
            }

            // Add user to village's parents collection
            db.collection("villages").document(invitation.villageID).collection("parents").document(userID).setData([
                "uid": userID,
                "name": session.userData["name"] as? String ?? "Unknown",
                "email": session.userData["email"] as? String ?? "",
                "fcmToken": session.userData["fcmToken"] as? String ?? ""
            ]) { error in
                if let error = error {
                    self.errorMessage = "Error adding to village: \(error.localizedDescription)"
                    self.showError = true
                    return
                }

                // Remove invitation
                db.collection("users").document(userID).collection("invitations").document(invitation.id).delete { error in
                    if let error = error {
                        self.errorMessage = "Error removing invitation: \(error.localizedDescription)"
                        self.showError = true
                        return
                    }
                    // Update session
                    session.fetchUserData(uid: userID)
                }
            }
        }
    }
}

