// KidHomeView.swift

import SwiftUI
import Firebase

struct KidHomeView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack(spacing: 20) {
            Text("Select an Option")
                .font(.headline)
            Button(action: {
                sendNotification(type: "Got Hurt")
            }) {
                Text("Got Hurt")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                sendNotification(type: "Unsafe")
            }) {
                Text("Unsafe")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                sendNotification(type: "Emergency")
            }) {
                Text("Emergency")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                sendNotification(type: "Reached Home")
            }) {
                Text("Reached Home")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
    }

    func sendNotification(type: String) {
        guard let user = session.user,
              let villageID = session.villageID,
              let name = session.userData["name"] as? String else {
            print("Missing user data")
            return
        }

        let db = Firestore.firestore()

        // Prepare notification data
        let notificationData: [String: Any] = [
            "villageID": villageID,
            "userID": user.uid,
            "name": name,
            "type": type,
            "timestamp": Timestamp()
        ]

        // Save notification request to Firestore
        db.collection("notificationRequests").addDocument(data: notificationData) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification request sent successfully.")
            }
        }
    }
}

