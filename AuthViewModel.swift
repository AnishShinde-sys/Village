import SwiftUI
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var user: AppUser?
    
    init() {
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let self = self else { return }
            self.userSession = result?.user
            self.fetchUser()
        }
    }
    
    func register(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Failed to register: \(error.localizedDescription)")
                return
            }
            guard let self = self else { return }
            guard let user = result?.user else { return }
            let data = ["email": email, "name": name, "uid": user.uid]
            Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                if let error = error {
                    print("Failed to upload user data: \(error.localizedDescription)")
                    return
                }
                self.userSession = user
                self.fetchUser()
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.user = nil
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() {
        guard let uid = self.userSession?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Failed to fetch user: \(error.localizedDescription)")
                return
            }
            guard let self = self else { return }
            guard let data = snapshot?.data() else { return }
            self.user = AppUser(
                id: uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? ""
            )
        }
    }
}
