//
//  ResQApp.swift
//  ResQ
//
//  Created by sym on 2025/11/19.
//

import SwiftUI

@main
struct ResQApp: App {

    @StateObject private var authManager = AuthManager.shared
    @StateObject private var locationManager = LocationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager.shared)
                .environmentObject(LocationManager.shared)
        }
    }
}
