//
//  NotificationManager.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import Foundation
import UserNotifications
import SwiftUI // For @Published

class NotificationManager: ObservableObject {
    // Published property to track if notifications are enabled by the user in settings.
    @Published var notificationsEnabled: Bool = false {
        didSet {
            // Persist the user's preference for notifications.
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }

    @Published var notificationCategories: Set<String> = [] {
        didSet {
            UserDefaults.standard.set(Array(notificationCategories), forKey: "notificationCategories")
        }
    }

    enum NotificationCategory: String, CaseIterable {
        case temperature = "TEMPERATURE_ALERT"
        case precipitation = "PRECIPITATION_ALERT"
        case wind = "WIND_ALERT"
        case daily = "DAILY_FORECAST"
        
        var title: String {
            switch self {
            case .temperature: return "Temperature Alerts"
            case .precipitation: return "Precipitation Alerts"
            case .wind: return "Wind Alerts"
            case .daily: return "Daily Forecast"
            }
        }
        
        var description: String {
            switch self {
            case .temperature: return "Get notified about extreme temperature changes"
            case .precipitation: return "Get notified about rain or snow"
            case .wind: return "Get notified about strong winds"
            case .daily: return "Get daily weather forecasts"
            }
        }
    }

    init() {
        // Load the saved preference for notifications when the manager is initialized.
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        if let categories = UserDefaults.standard.stringArray(forKey: "notificationCategories") {
            self.notificationCategories = Set(categories)
        }
        setupNotificationCategories()
        checkNotificationStatus() // Check the actual system status on init
    }

    private func setupNotificationCategories() {
        let temperatureCategory = UNNotificationCategory(
            identifier: NotificationCategory.temperature.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze for 1 hour",
                    options: .authenticationRequired
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let precipitationCategory = UNNotificationCategory(
            identifier: NotificationCategory.precipitation.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze for 1 hour",
                    options: .authenticationRequired
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            temperatureCategory,
            precipitationCategory
        ])
    }

    // Requests authorization from the user to send notifications.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async { // Ensure UI updates on main thread
                if granted {
                    print("Notification permissions granted.")
                    self.notificationsEnabled = true
                    self.setupNotificationCategories()
                } else if let error = error {
                    print("Notification permissions denied or error: \(error.localizedDescription)")
                    self.notificationsEnabled = false
                } else {
                    print("Notification permissions denied by user.")
                    self.notificationsEnabled = false
                }
            }
        }
    }

    // Checks the current notification authorization status.
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }

    // Schedules a local notification.
    func scheduleNotification(
        title: String,
        body: String,
        category: NotificationCategory,
        sound: UNNotificationSound = .default,
        triggerDate: Date? = nil,
        identifier: String = UUID().uuidString
    ) {
        // Only schedule if notifications are enabled by the user.
        guard notificationsEnabled else {
            print("Notifications are disabled by user, not scheduling.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.categoryIdentifier = category.rawValue

        let trigger: UNNotificationTrigger?
        if let date = triggerDate {
            // Schedule for a specific date and time (e.g., tomorrow morning).
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // Schedule to deliver immediately or after a short time (e.g., 5 seconds for a test).
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // For demonstration
        }

        if let trigger = trigger {
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled: \(identifier)")
                }
            }
        }
    }

    func toggleNotificationCategory(_ category: NotificationCategory) {
        if notificationCategories.contains(category.rawValue) {
            notificationCategories.remove(category.rawValue)
        } else {
            notificationCategories.insert(category.rawValue)
        }
    }

    func isCategoryEnabled(_ category: NotificationCategory) -> Bool {
        return notificationCategories.contains(category.rawValue)
    }

    // Removes all pending notifications.
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications removed.")
    }

    // Removes specific pending notifications by identifiers.
    func removePendingNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Removed pending notifications with identifiers: \(identifiers)")
    }
}
