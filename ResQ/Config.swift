import Foundation


struct Config {
    // MARK: - API Configuration
    // For iOS Simulator: Use "http://localhost:8000" if backend is on same Mac
    // For physical device: Use your Mac's local IP (e.g., "http://192.168.100.187:8000")
    // For production: Use your production server URL
    
    #if targetEnvironment(simulator)
        // iOS Simulator - can use localhost
        static let baseURL = "http://127.0.0.1:8000"
    #else
        // Physical device - use network IP
        static let baseURL = "http://192.168.5.125:8000"
    #endif

    static var apiURL: String {
        return baseURL
    }
    
    // Helper function to test if backend is reachable
    static func getBackendURL() -> String {
        return baseURL
    }

    struct Endpoints {
        static let user = "/user"
        static let alert = "/alert"
        static let translate = "/translate"
        static let sensor = "/sensor"

        static let login = "/user/login"
        static let register = "/user/register"
        static let userLocations = "\(user)/locations"
        static let userLocation = "\(user)/location"
        static let userProfile = "\(user)"

        static let alerts = alert
        static let nearbyAlerts = "\(alert)/nearby"

        static let translateText = "\(translate)/translate"
        static let languages = "\(translate)/languages"

        static let sensorData = "\(sensor)/data"
        static let sensorStatus = "\(sensor)/status"
    }
}
