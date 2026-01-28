import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let session: URLSession
    private let baseURL: String
    
    init() {
        self.baseURL = Config.apiURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    // ✅ MARK: - Generic Request Method
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<T, APIError> {

        let fullURL = "\(baseURL)\(endpoint)"
        guard let url = URL(string: fullURL) else {
            print("❌ API Error: Invalid URL - \(fullURL)")
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        print("🌐 API Request: \(method) \(fullURL)")

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            do {
                let encodedBody = try JSONEncoder().encode(body)
                request.httpBody = encodedBody
                if let jsonString = String(data: encodedBody, encoding: .utf8) {
                    print("📤 Request Body: \(jsonString)")
                }
            } catch {
                print("❌ Encoding Error: \(error.localizedDescription)")
                return Fail(error: APIError.decodingError(error)).eraseToAnyPublisher()
            }
        }

        // ✅ JSONDecoder ကို configure လုပ် (snake_case အတွက်)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                print("📥 API Response: Status \(httpResponse.statusCode)")

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("❌ Error Response: \(responseString)")
                    }
                    throw APIError.httpError(httpResponse.statusCode)
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    print("✅ Response Body: \(responseString)")
                }

                return data
            }
            .decode(type: T.self, decoder: decoder)   // ✅ အရေးကြီး: T.self
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                if error is DecodingError {
                    print("❌ DecodingError FULL =>", error)
                    return .decodingError(error)
                }
                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - User Endpoints
    func login(userId: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let loginData = UserLogin(userId: userId, password: password)
        return request(endpoint: Config.Endpoints.login, method: "POST", body: loginData)
    }
    
    func register(_ userData: UserRegister) -> AnyPublisher<RegisterResponse, APIError> {
        return request(endpoint: Config.Endpoints.register, method: "POST", body: userData)
    }
    
    func getUser(userId: String) -> AnyPublisher<User, APIError> {
        return request(endpoint: "\(Config.Endpoints.user)/\(userId)")
    }
    
    // MARK: - Location Endpoints
    func getUserLocations(userId: String) -> AnyPublisher<LocationResponse, APIError> {
        return request(endpoint: "\(Config.Endpoints.userLocations)?user_id=\(userId)")
    }
    
    func createLocation(_ location: LocationData) -> AnyPublisher<LocationResponse, APIError> {
        return request(endpoint: Config.Endpoints.userLocation, method: "POST", body: location)
    }
    
    func updateLocation(userId: String, latitude: Double, longitude: Double, address: String?, alertRadius: Double) -> AnyPublisher<LocationResponse, APIError> {
        var urlString = "\(Config.Endpoints.userLocation)?user_id=\(userId)&latitude=\(latitude)&longitude=\(longitude)&alert_radius=\(alertRadius)"
        if let address = address {
            urlString += "&address=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        return request(endpoint: urlString, method: "PUT")
    }
    
    func deleteLocation(userId: String, locationId: String) -> AnyPublisher<LocationResponse, APIError> {
        // The API expects location_id as Int, but our model uses String UUID
        // We'll need to handle this conversion or update the API
        // For now, try to parse as Int if possible
        guard let intID = Int(locationId) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        let deleteData = LocationDelete(userId: userId, locationId: intID )
        return request(
            endpoint: Config.Endpoints.userLocation,
            method: "DELETE",
            body: deleteData)
    }
    
    // MARK: - Alert Endpoints
    func getAlerts(language: String? = nil, severity: String? = nil, category: String? = nil) -> AnyPublisher<[Alert], APIError> {
        var endpoint = Config.Endpoints.alerts
        var queryItems: [String] = []
        
        if let language = language {
            queryItems.append("language=\(language)")
        }
        if let severity = severity {
            queryItems.append("severity=\(severity)")
        }
        if let category = category {
            queryItems.append("category=\(category)")
        }
        
        if !queryItems.isEmpty {
            endpoint += "?" + queryItems.joined(separator: "&")
        }
        
        return request(endpoint: endpoint)
    }
    
    func getNearbyAlerts(latitude: Double, longitude: Double, radiusKm: Double = 50.0, language: String? = nil) -> AnyPublisher<[Alert], APIError> {
        var endpoint = "\(Config.Endpoints.nearbyAlerts)/\(latitude)/\(longitude)?radius_km=\(radiusKm)"
        if let language = language {
            endpoint += "&language=\(language)"
        }
        return request(endpoint: endpoint)
    }
    
    // MARK: - Translation Endpoints
    func translate(_ translationRequest: TranslationRequest) -> AnyPublisher<TranslationResponse, APIError> {
        return request(endpoint: Config.Endpoints.translateText, method: "POST", body: translationRequest)
    }
    
    
    func getSupportedLanguages() -> AnyPublisher<[LanguageInfo], APIError> {
        return request(endpoint: Config.Endpoints.languages)
    }
}

