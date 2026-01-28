import Foundation

// MARK: - User Models
struct UserLogin: Codable {
    let userId: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case password
    }
}

struct UserRegister: Codable {
    let userId: String
    let password: String
    let confirmPassword: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let preferredLanguage: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case password
        case confirmPassword = "confirm_password"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case preferredLanguage = "preferred_language"
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let user: User
}

struct RegisterResponse: Codable {
    let success: Bool
    let message: String
    let user: User
}

struct User: Codable, Identifiable {
    let id: String
    let userId: String?
    let firstName: String?
    let lastName: String?
    let name: String?
    let email: String?
    let phone: String?
    let preferredLanguage: String?

    let notificationPreferences: NotificationPreferences?
    let alertCategories: [String]?
    let severityThreshold: String?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case email
        case phone
        case preferredLanguage = "preferred_language"
        case notificationPreferences = "notification_preferences"
        case alertCategories = "alert_categories"
        case severityThreshold = "severity_threshold"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct NotificationPreferences: Codable {
    let email: Bool
    let push: Bool
    let sms: Bool
}

