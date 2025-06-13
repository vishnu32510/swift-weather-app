//
//  SettingsView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI

struct SettingsView: View {
    // Access the NotificationManager from the environment to control notification settings.
    @EnvironmentObject private var notificationManager: NotificationManager
    // Environment value to dismiss the sheet.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle(isOn: $notificationManager.notificationsEnabled) {
                        Text("Enable Weather Notifications")
                    }
                    .onChange(of: notificationManager.notificationsEnabled) { newValue in
                        // If notifications are enabled, request authorization if not already granted.
                        if newValue {
                            notificationManager.requestAuthorization()
                        }
                    }
                    // Inform user about notification status and how to change it in system settings.
                    Text("You can manage notification permissions in your iPhone's Settings app.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Dismiss the settings sheet.
                    }
                }
            }
        }
    }
}
