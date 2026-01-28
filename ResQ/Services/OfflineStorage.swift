import Foundation
import Combine

/// Manages offline data storage and synchronization
class OfflineStorage: ObservableObject {
    static let shared = OfflineStorage()
    
    @Published var isOfflineMode = false
    @Published var lastSyncDate: Date?
    
    private let storageService = StorageService.shared
    private let apiService = APIService.shared
    
    private init() {
        lastSyncDate = storageService.getLastSyncDate()
        checkNetworkStatus()
    }
    
    // MARK: - Network Status
    
    private func checkNetworkStatus() {
        // Simple check - in production, use Network framework
        // For now, we'll detect based on API failures
    }
    
    func setOfflineMode(_ offline: Bool) {
        isOfflineMode = offline
    }
    
    // MARK: - Sync Management
    
    func syncAlerts(userId: String) -> AnyPublisher<[Alert], APIError> {
        // Try to fetch from API first
        return apiService.getAlerts()
            .handleEvents(receiveOutput: { [weak self] alerts in
                // Cache for offline access
                self?.storageService.cacheAlerts(alerts)
                self?.storageService.saveLastSyncDate(Date())
                self?.lastSyncDate = Date()
            })
            .catch { [weak self] error -> AnyPublisher<[Alert], APIError> in
                // Fallback to cached data if network fails
                if let cached = self?.storageService.getCachedAlerts() {
                    return Just(cached)
                        .setFailureType(to: APIError.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncLocations(userId: String) -> AnyPublisher<[UserLocation], APIError> {
        return apiService.getUserLocations(userId: userId)
            .map { $0.locations }
            .handleEvents(receiveOutput: { [weak self] locations in
                // Cache for offline access
                self?.storageService.cacheLocations(locations)
                self?.storageService.saveLastSyncDate(Date())
                self?.lastSyncDate = Date()
            })
            .catch { [weak self] error -> AnyPublisher<[UserLocation], APIError> in
                // Fallback to cached data if network fails
                if let cached = self?.storageService.getCachedLocations() {
                    return Just(cached)
                        .setFailureType(to: APIError.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Offline Data Access
    
    func getOfflineAlerts() -> [Alert] {
        return storageService.getCachedAlerts() ?? []
    }
    
    func getOfflineLocations() -> [UserLocation] {
        return storageService.getCachedLocations() ?? []
    }
    
    // MARK: - Clear Cache
    
    func clearCache() {
        storageService.remove(forKey: StorageService.Keys.cachedAlerts)
        storageService.remove(forKey: StorageService.Keys.cachedLocations)
        storageService.remove(forKey: StorageService.Keys.lastSyncDate)
        lastSyncDate = nil
    }
}

