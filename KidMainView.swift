// KidMainView.swift

import SwiftUI

struct KidMainView: View {
    var body: some View {
        TabView {
            KidHomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            LocationSharingView()
                .tabItem {
                    Label("Share Location", systemImage: "location")
                }
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
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

struct KidMainView_Previews: PreviewProvider {
    static var previews: some View {
        KidMainView()
    }
}

