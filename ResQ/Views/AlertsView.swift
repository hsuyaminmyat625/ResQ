import SwiftUI
import Combine
import MapKit

struct AlertsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var viewModel = AlertsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading alerts...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadAlerts(locationManager: locationManager, userLanguage: authManager.currentUser?.preferredLanguage)
                        }
                    }
                } else if viewModel.alerts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("No Active Alerts")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("You're safe! No alerts in your area.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(viewModel.alerts) { alert in
                        AlertRow(alert: alert)
                    }
                }
            }
            .navigationTitle("Alerts")
            .refreshable {
                viewModel.loadAlerts(locationManager: locationManager, userLanguage: authManager.currentUser?.preferredLanguage)
            }
            .onAppear {
                viewModel.loadAlerts(locationManager: locationManager, userLanguage: authManager.currentUser?.preferredLanguage)
            }
        }
    }
}

struct AlertRow: View {
    let alert: Alert
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.severityEnum.icon)
                .foregroundStyle(colorForSeverity(alert.severityEnum))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(alert.title ?? "No title")
                    .font(.headline)
                
                Text(alert.description ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 10) {
                    Label(
                        (alert.category ?? "unknown").capitalized,
                        systemImage: "tag.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Label(alert.createdAt ?? "-", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // location optional safe
                    Label(
                        alert.createdAt ?? "-",
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorForSeverity(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadAlerts(locationManager: LocationManager, userLanguage: String?) {
        isLoading = true
        errorMessage = nil
        
        let publisher: AnyPublisher<[Alert], APIError>
        
        if let location = locationManager.currentLocation {
            publisher = apiService.getNearbyAlerts(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                language: userLanguage
            )
        } else {
            publisher = apiService.getAlerts(language: userLanguage)
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] alerts in
                    self?.alerts = alerts.filter { $0.isActive ?? true }
                }
            )
            .store(in: &cancellables)
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView()
            .environmentObject(AuthManager.shared)
            .environmentObject(LocationManager.shared)
    }
}

