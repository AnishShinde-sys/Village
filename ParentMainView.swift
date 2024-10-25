// ParentMainView.swift

import SwiftUI

struct ParentMainView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            LocationSharingView()
                .tabItem {
                    Label("Share Location", systemImage: "location")
                }
            VillageView()
                .tabItem {
                    Label("Village", systemImage: "person.3")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ParentMainView_Previews: PreviewProvider {
    static var previews: some View {
        ParentMainView()
    }
}

