import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct VillageApp: App {
    @StateObject var session = SessionStore()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
