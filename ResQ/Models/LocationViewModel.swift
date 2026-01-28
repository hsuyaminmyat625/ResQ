import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationViewModel: ObservableObject {
    @Published var locations: [UserLocation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// Used by LocationView to know whether it should open the AddLocation sheet after location arrives
    var pendingSave: Bool = false

    private var cancellables = Set<AnyCancellable>()

    /// TODO: Replace with AuthManager.currentUser?.userId
    let userId: String = "hsuyamin"

    // MARK: - Fetch

    func fetchLocations() {
        isLoading = true
        errorMessage = nil

        APIService.shared.getUserLocations(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] res in
                self?.locations = res.locations
            }
            .store(in: &cancellables)
    }

    // MARK: - Save (from device CLLocation)

    func saveLocationFromDevice(_ loc: CLLocation) {
        saveLocation(
            name: nil,
            address: nil,
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            alertRadius: 50
        )
    }

    // MARK: - Save (from sheet / custom values)

    func saveLocation(
        name: String?,
        address: String?,
        latitude: Double,
        longitude: Double,
        alertRadius: Double
    ) {
        isLoading = true
        errorMessage = nil

        let body = LocationData(
            userId: userId,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            alertRadius: alertRadius
        )

        APIService.shared.createLocation(body)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.errorMessage = nil
                self.fetchLocations()
            }
            .store(in: &cancellables)
    }

    // MARK: - Delete (optional)

    func deleteLocation(locationId: String) {
        isLoading = true
        errorMessage = nil

        APIService.shared.deleteLocation(userId: userId, locationId: locationId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] res in
                self?.locations = res.locations
            }
            .store(in: &cancellables)
    }
}
