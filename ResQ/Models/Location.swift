import Foundation
import CoreLocation

struct LocationResponse: Codable {
    let success: Bool
    let message: String
    let locations: [UserLocation]
}

struct UserLocation: Codable, Identifiable {
    let id: String
    let userId: String?
    let name: String?
    let address: String?
    let latitude: Double
    let longitude: Double
    let alertRadius: Double?

    let isPrimary: Bool?      // ✅ optional
    let isActive: Bool?       // ✅ optional
    let createdAt: String?    // ✅ optional
    let updatedAt: String?    // ✅ optional

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case address
        case latitude
        case longitude
        case alertRadius = "alert_radius"
        case isPrimary = "is_primary"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct LocationData: Codable {
    let userId: String
    let name: String?
    let address: String?
    let latitude: Double
    let longitude: Double
    let alertRadius: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case address
        case latitude
        case longitude
        case alertRadius = "alert_radius"
    }
}



struct LocationDelete: Codable {
    let userId: String
    let locationId: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case locationId = "location_id"
    }
}

