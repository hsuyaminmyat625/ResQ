import SwiftUI
import MapKit
import CoreLocation
import Combine

struct LocationView: View {
    @StateObject private var viewModel = LocationViewModel()
    @ObservedObject private var locationManager = LocationManager.shared

    @State private var showingAddSheet = false
    @State private var selectedCoord: CLLocationCoordinate2D?
    @State private var selectedAddress: String?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.68, longitude: 135.17),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                mapSection
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    // ✅ Ask for permission + request one-shot location
                    viewModel.pendingSave = true
                    viewModel.errorMessage = "Getting current location..."
                    locationManager.requestPermissionAndStart(oneShot: true)
                } label: {
                    HStack {
                        if viewModel.isLoading { ProgressView() }
                        Text("Add Location")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("My Locations")
            .onAppear {
                // Load saved locations when screen opens
                viewModel.fetchLocations()
            }
            .onReceive(locationManager.$currentLocation.compactMap { $0 }) { loc in
                // Move map to current location
                region.center = loc.coordinate

                // If user tapped Add Location, open sheet with current coordinate
                if viewModel.pendingSave {
                    viewModel.pendingSave = false

                    selectedCoord = loc.coordinate
                    // ✅ if you added reverse geocode into LocationManager
                    selectedAddress = locationManager.currentAddress

                    showingAddSheet = true
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if let coord = selectedCoord {
                    AddLocationSheet(
                        coordinate: coord,
                        defaultAddress: selectedAddress
                    ) { name, address, radius in
                        viewModel.saveLocation(
                            name: name,
                            address: address,
                            latitude: coord.latitude,
                            longitude: coord.longitude,
                            alertRadius: radius
                        )
                    }
                }
            }
        }
    }

    private var mapSection: some View {
        Map(coordinateRegion: $region, annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                LocationPinView(
                    title: location.name ?? location.address ?? "Saved Location",
                    isPrimary: location.isPrimary ?? false
                )
            }
        }
    }
}

private struct LocationPinView: View {
    let title: String
    let isPrimary: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: isPrimary ? "house.fill" : "mappin.circle.fill")
                .font(.title2)

            Text(title)
                .font(.caption)
                .padding(6)
                .background(Color.white.opacity(0.01)) // optional VectorKit warning workaround
                .cornerRadius(8)
        }
    }
}
