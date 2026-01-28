import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    @Published var currentLocation: CLLocation?
    @Published var currentAddress: String?          // ✅ reverse geocode result
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var isOneShot = true
    private var isGeocoding = false

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    /// Call this when user taps "Add Location"
    func requestPermissionAndStart(oneShot: Bool = true) {
        errorMessage = nil
        isOneShot = oneShot

        let status = manager.authorizationStatus
        authorizationStatus = status

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()

        case .denied, .restricted:
            errorMessage = "Location access is denied. Please enable it in Settings."

        @unknown default:
            break
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        currentLocation = loc
        errorMessage = nil

        // ✅ reverse geocode once per update (avoid spamming)
        reverseGeocodeIfNeeded(loc)

        if isOneShot {
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocodeIfNeeded(_ location: CLLocation) {
        guard !isGeocoding else { return }
        isGeocoding = true

        // If there is an ongoing geocode request, cancel it first
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            self.isGeocoding = false

            if let error = error {
                self.errorMessage = "Reverse geocode failed: \(error.localizedDescription)"
                self.currentAddress = nil
                return
            }

            guard let pm = placemarks?.first else {
                self.currentAddress = nil
                return
            }

            // ✅ build a nice address string
            let name = pm.name
            let city = pm.locality
            let state = pm.administrativeArea
            let country = pm.country

            let address = [name, city, state, country]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")

            self.currentAddress = address.isEmpty ? nil : address
        }
    }
}
