// VillageView.swift


import SwiftUI
import Firebase


struct VillageView: View {
    @EnvironmentObject var session: SessionStore
    @State private var parentsList: [ParentUser] = []
    @State private var kidsList: [Kid] = []
    @State private var showingAddPersonSheet = false


    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Parents")) {
                    ForEach(parentsList) { parent in
                        Text(parent.name)
                    }
                }
                Section(header: Text("Kids")) {
                    ForEach(kidsList) { kid in
                        Text(kid.name)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Village")
            .navigationBarItems(trailing: session.isParent ? Button(action: {
                showingAddPersonSheet = true
            }) {
                Image(systemName: "person.badge.plus")
            } : nil)
            .onAppear {
                fetchVillageMembers()
            }
            .sheet(isPresented: $showingAddPersonSheet) {
                AddPersonView()
                    .environmentObject(session)
            }
        }
    }


    func fetchVillageMembers() {
        let db = Firestore.firestore()
        guard let villageID = session.villageID else { return }


        // Fetch parents
        db.collection("villages").document(villageID).collection("parents")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching parents: \(error.localizedDescription)")
                    return
                }
                parentsList = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let uid = data["uid"] as? String ?? UUID().uuidString
                    let name = data["name"] as? String ?? "Unknown"
                    let email = data["email"] as? String ?? ""
                    return ParentUser(id: uid, name: name, email: email)
                } ?? []
            }


        // Fetch kids
        db.collection("villages").document(villageID).collection("kids")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching kids: \(error.localizedDescription)")
                    return
                }
                kidsList = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let uid = data["uid"] as? String ?? UUID().uuidString
                    let name = data["name"] as? String ?? "Unknown"
                    let email = data["email"] as? String ?? ""
                    return Kid(id: uid, name: name, email: email)
                } ?? []
            }
    }
}

