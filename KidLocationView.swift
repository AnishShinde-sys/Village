//
//  KidLocationView.swift
//  VillageApp
//
//  Created by Anish Shinde on 10/24/24.
//


// KidLocationView.swift

import SwiftUI
import MapKit
import Firebase
import CoreLocation

struct KidLocationView: View {
    @StateObject private var locationManager = KidLocationManager()
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack {
            if let location = locationManager.currentLocation {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))
                .edgesIgnoringSafeArea(.all)
            } else {
                Text("Obtaining location...")
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            locationManager.session = session
        }
    }
}

class KidLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    private var locationManager = CLLocationManager()
    var session: SessionStore?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startUpdatingLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied.")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let session = session else { return }
        currentLocation = location

        // Update location to Firestore
        let db = Firestore.firestore()
        if let userID = session.user?.uid {
            db.collection("locations").document(userID).setData([
                "userID": userID,
                "name": session.userData["name"] as? String ?? "Unknown",
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "timestamp": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("Error updating location: \(error.localizedDescription)")
                } else {
                    print("Location updated successfully.")
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
