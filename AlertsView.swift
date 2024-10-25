import SwiftUI
import Firebase

struct AlertsView: View {
    @Binding var alerts: [AlertItem]
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            List(alerts) { alert in
                VStack(alignment: .leading) {
                    Text("\(alert.kidName) is \(alert.status)!")
                        .font(.headline)
                    Text("Time: \(alert.timestamp.formatted())")
                        .font(.subheadline)
                    HStack {
                        if let response = alert.responders[session.user?.uid ?? ""] {
                            Text(response ? "You have responded: Yes" : "You have responded: No")
                                .foregroundColor(response ? .green : .red)
                        } else {
                            Button(action: {
                                respondToAlert(alertID: alert.id, response: true)
                            }) {
                                Text("Yes, I can respond")
                                    .foregroundColor(.green)
                            }
                            Button(action: {
                                respondToAlert(alertID: alert.id, response: false)
                            }) {
                                Text("No, I can't respond")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
        }
    }
    
    func respondToAlert(alertID: String, response: Bool) {
        let db = Firestore.firestore()
        guard let userID = session.user?.uid else { return }
        db.collection("alerts").document(alertID).updateData([
            "responders.\(userID)": response
        ]) { error in
            if let error = error {
                print("Error responding to alert: \(error.localizedDescription)")
            }
        }
    }
}

struct AlertItem: Identifiable {
    var id: String
    var kidID: String
    var status: String
    var timestamp: Date
    var responders: [String: Bool]
    
    var kidName: String {
        // For simplicity, return a placeholder name
        return "Child"
    }
}
