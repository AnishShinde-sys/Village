// Models.swift

import Foundation
import CoreLocation

struct UserLocation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isParent: Bool
}

struct ParentUser: Identifiable {
    let id: String
    let name: String
    let email: String
}

struct Kid: Identifiable {
    let id: String
    let name: String
    let email: String
}

struct ParentInvitation: Identifiable {
    var id: String
    var senderName: String
    var villageID: String
}

