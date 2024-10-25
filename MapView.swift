// MapView.swift

import SwiftUI
import MapKit
import Firebase

struct MapView: View {
    @EnvironmentObject var session: SessionStore
    @State private var region = MKCoordinateRegion()
    @State private var userLocations: [UserLocation] = []

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: userLocations) { user in
            MapAnnotation(coordinate: user.coordinate) {
                VStack {
                    Image(systemName: user.isParent ? "person.fill" : "person.fill")
                        .foregroundColor(user.isParent ? .blue : .green)
                        .font(.title)
                    Text(user.name)
                        .font(.caption)
                        .padding(5)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(5)
                }
            }
        }
        .onAppear {
            fetchUserLocations()
        }
    }

    func fetchUserLocations() {
        let db = Firestore.firestore()
        guard let villageID = session.villageID else {
            print("MapView: session.villageID is nil")
            return
        }

        // Fetch parents and kids in the village
        let parentsRef = db.collection("villages").document(villageID).collection("parents")
        let kidsRef = db.collection("villages").document(villageID).collection("kids")

        parentsRef.getDocuments { parentSnapshot, error in
            if let error = error {
                print("Error fetching parents: \(error.localizedDescription)")
                return
            }
            let parentIDs = parentSnapshot?.documents.map { $0.documentID } ?? []

            kidsRef.getDocuments { kidSnapshot, error in
                if let error = error {
                    print("Error fetching kids: \(error.localizedDescription)")
                    return
                }
                let kidIDs = kidSnapshot?.documents.map { $0.documentID } ?? []

                let allUserIDs = parentIDs + kidIDs
                fetchLocations(for: allUserIDs, parentIDs: parentIDs)
            }
        }
    }

    func fetchLocations(for userIDs: [String], parentIDs: [String]) {
        let db = Firestore.firestore()
        if userIDs.isEmpty {
            self.userLocations = []
            return
        }
        db.collection("locations")
            .whereField("userID", in: userIDs)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching locations: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var locations: [UserLocation] = []
                for document in documents {
                    let data = document.data()
                    guard
                        let userID = data["userID"] as? String,
                        let name = data["name"] as? String,
                        let latitude = data["latitude"] as? Double,
                        let longitude = data["longitude"] as? Double
                    else {
                        continue
                    }

                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let isParent = parentIDs.contains(userID)
                    let userLocation = UserLocation(id: document.documentID, name: name, coordinate: coordinate, isParent: isParent)
                    locations.append(userLocation)
                }

                DispatchQueue.main.async {
                    self.userLocations = locations
                    updateRegion()
                }
            }
    }

    func updateRegion() {
        guard !userLocations.isEmpty else {
            // Set a default region if no users are present
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
            return
        }

        let latitudes = userLocations.map { $0.coordinate.latitude }
        let longitudes = userLocations.map { $0.coordinate.longitude }

        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2

        let spanLat = (maxLat - minLat) * 1.5
        let spanLon = (maxLon - minLon) * 1.5

        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }
}

