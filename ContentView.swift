import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if !session.isSignedIn {
                SignInSignUpView()
                    .onAppear {
                        print("ContentView: Showing SignInSignUpView")
                    }
            } else if !session.isUserDataLoaded {
                LoadingView()
                    .onAppear {
                        print("ContentView: Loading user data...")
                    }
            } else {
                if session.isParent {
                    ParentMainView()
                        .onAppear {
                            print("ContentView: Showing ParentMainView")
                        }
                } else {
                    KidMainView()
                        .onAppear {
                            print("ContentView: Showing KidMainView")
                        }
                }
            }
        }
        .onAppear {
            print("ContentView: Current state - isSignedIn: \(session.isSignedIn), isUserDataLoaded: \(session.isUserDataLoaded), isParent: \(session.isParent)")
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Text("Loading...")
            ProgressView()
        }
    }
}
