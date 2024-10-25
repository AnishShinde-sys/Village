// AppLocationManager.swift

import Foundation
import CoreLocation
import Firebase

class AppLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    private let manager = CLLocationManager()
    private var userID: String?
    private var userName: String?
    private var villageID: String?
    private let db = Firestore.firestore()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
    }

    func setUserID(_ id: String, name: String) {
        self.userID = id
        self.userName = name
    }

    func setVillageID(_ id: String) {
        self.villageID = id
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let userID = self.userID else { return }
        self.location = location

        // Upload location to Firestore
        uploadLocation(location)
    }

    func uploadLocation(_ location: CLLocation) {
        guard let userID = self.userID else { return }
        db.collection("locations").document(userID).setData([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(),
            "userID": userID,
            "name": userName ?? "Unknown",
            "villageID": villageID ?? ""
        ], merge: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}

