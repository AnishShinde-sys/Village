// LocationManager.swift

import Foundation
import CoreLocation
import Firebase

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    private let manager = CLLocationManager()
    private var userID: String?
    private var villageID: String?
    private var db = Firestore.firestore()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }

    func setUserID(_ id: String) {
        self.userID = id
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let userID = self.userID else { return }
        self.location = location

        // Upload location to Firestore
        db.collection("locations").document(userID).setData([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(),
            "userID": userID,
            "villageID": villageID ?? ""
        ], merge: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
