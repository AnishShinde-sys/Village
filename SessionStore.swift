// SessionStore.swift


import Foundation
import FirebaseAuth
import Firebase
import FirebaseMessaging


class SessionStore: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isParent: Bool = false
    @Published var userData: [String: Any] = [:]
    @Published var isSignedIn: Bool = false
    @Published var villageID: String?
    @Published var isUserDataLoaded: Bool = false
    var handle: AuthStateDidChangeListenerHandle?


    init() {
        print("SessionStore: Initializing")
        listen()
    }


    func listen() {
        print("SessionStore: Setting up auth listener")
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }


        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            let uid = user?.uid ?? "nil"
            print("SessionStore: Auth state changed - User: \(uid)")
            self.user = user
            if let user = user {
                print("SessionStore: User is signed in, fetching user data")
                self.fetchUserData(uid: user.uid)
            } else {
                print("SessionStore: User is signed out, resetting state")
                self.resetState()
            }
        }
    }


    private func resetState() {
        self.isParent = false
        self.userData = [:]
        self.villageID = nil
        self.isSignedIn = false
        self.isUserDataLoaded = false
    }


    func fetchUserData(uid: String) {
        print("SessionStore: Fetching user data for uid: \(uid)")
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }


            if let error = error {
                print("SessionStore: Error fetching user data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.resetState()
                }
                return
            }


            if let document = document, document.exists {
                let data = document.data() ?? [:]
                print("SessionStore: User data fetched: \(data)")


                DispatchQueue.main.async {
                    // Handle 'isParent' being stored as Bool, Int, or String
                    if let isParentValue = data["isParent"] as? Bool {
                        self.isParent = isParentValue
                    } else if let isParentInt = data["isParent"] as? Int {
                        self.isParent = isParentInt != 0
                    } else if let isParentString = data["isParent"] as? String {
                        self.isParent = (isParentString == "true")
                    } else {
                        self.isParent = false
                    }


                    self.userData = data
                    self.villageID = data["villageID"] as? String
                    let isParentStr = self.isParent ? "true" : "false"
                    let villageIDStr = self.villageID ?? "nil"
                    print("SessionStore: isParent is \(isParentStr), villageID is \(villageIDStr)")
                    self.isSignedIn = true
                    self.isUserDataLoaded = true
                    self.saveFCMToken()
                }
            } else {
                print("SessionStore: No user document found")
                DispatchQueue.main.async {
                    self.resetState()
                }
            }
        }
    }


    func saveFCMToken() {
        guard let user = user else { return }
        let token = Messaging.messaging().fcmToken
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "fcmToken": token ?? ""
        ]) { error in
            if let error = error {
                print("Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token saved successfully.")
            }
        }


        // Update token in village's collection
        if let villageID = villageID {
            let userTypeCollection = isParent ? "parents" : "kids"
            db.collection("villages").document(villageID).collection(userTypeCollection).document(user.uid).updateData([
                "fcmToken": token ?? ""
            ]) { error in
                if let error = error {
                    print("Error updating FCM token in village: \(error.localizedDescription)")
                } else {
                    print("FCM token updated in village.")
                }
            }
        }
    }


    func signOut() {
        print("SessionStore: Attempting to sign out")
        do {
            try Auth.auth().signOut()
            print("SessionStore: Sign out successful")
            self.resetState()
            self.user = nil
        } catch let error {
            print("SessionStore: Error signing out: \(error.localizedDescription)")
        }
    }


    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

