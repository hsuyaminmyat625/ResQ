import SwiftUI
import Combine

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
            
            LocationView()
                .tabItem {
                    Label("Locations", systemImage: "location.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

