//
//  MobileWeatherAppApp.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI

@main
struct MobileWeatherAppApp: App {
    // Initialize NotificationManager to handle notification setup on app launch.
    // It's created here to ensure it's available throughout the app lifecycle.
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            // The ContentView is the initial view of the application.
            // We inject the notificationManager into the environment,
            // making it accessible to any subviews that need to interact with notifications.
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}
