// LocationSharingView.swift

import SwiftUI
import CoreLocation
import Firebase

struct LocationSharingView: View {
    @StateObject var locationManager = AppLocationManager()
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Your location is being shared.")
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
            } else {
                Text("Fetching location...")
            }
        }
        .onAppear {
            if let userID = session.user?.uid {
                let userName = session.userData["name"] as? String ?? "Unknown"
                locationManager.setUserID(userID, name: userName)
                locationManager.setVillageID(session.villageID ?? "")
                locationManager.startUpdating()
            }
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
    }
}

