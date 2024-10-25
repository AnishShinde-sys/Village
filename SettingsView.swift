import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Button(action: {
                        session.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }

                // Add more settings options here
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

