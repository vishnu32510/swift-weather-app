//
//  OpenMeteoWeatherAppApp.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/14/25.
//

import SwiftUI

@main
struct OpenMeteoWeatherApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var notificationManager = NotificationManager()
    private let backgroundTaskManager = BackgroundTaskManager()
    
    init() {
        backgroundTaskManager.registerBackgroundTask()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                backgroundTaskManager.scheduleAppRefresh()
            }
        }
    }
}
