import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Static Identifiers
    // Using static constants prevents typos when using these IDs elsewhere.
    static let weatherAlertCategoryID = "WEATHER_ALERT"
    static let dailyForecastCategoryID = "DAILY_FORECAST"
    static let dailyForecastRequestID = "DAILY_MORNING_FORECAST"

    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Authorization and Setup
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.setupNotificationCategories()
                }
            }
        }
    }
    
    private func setupNotificationCategories() {
        let weatherAlertCategory = UNNotificationCategory(
            identifier: Self.weatherAlertCategoryID,
            actions: [
                UNNotificationAction(identifier: "VIEW_DETAILS", title: "View Details", options: .foreground),
                // The snooze action will now trigger the correct logic
                UNNotificationAction(identifier: "SNOOZE", title: "Snooze for 30 Min", options: [])
            ],
            intentIdentifiers: [], options: []
        )
        
        let dailyForecastCategory = UNNotificationCategory(
            identifier: Self.dailyForecastCategoryID,
            actions: [
                UNNotificationAction(identifier: "VIEW_FORECAST", title: "View Forecast", options: .foreground)
            ],
            intentIdentifiers: [], options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([weatherAlertCategory, dailyForecastCategory])
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedules an immediate weather alert (e.g., for rain starting soon).
    func scheduleWeatherAlert(title: String, body: String, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = Self.weatherAlertCategoryID
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds to give user time to exit app
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Schedules the daily 7 AM forecast notification.
    /// - Parameter dailyForecast: The `Daily` forecast object from the WeatherService.
    func scheduleDailyForecast(dailyForecast: Daily) {
        // First, remove the previous morning forecast to ensure it's up-to-date.
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.dailyForecastRequestID])
        
        // Use the first day's data for today's forecast.
        guard let maxTemp = dailyForecast.temperature2MMax.first,
              let weatherCode = dailyForecast.weatherCode.first else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Today's Forecast"
        
        // BUG FIX: Use the correct daily forecast data, not the current temperature.
        let weatherDescription = WeatherCodeMapper.description(for: weatherCode ?? 0)
        content.body = "Today will be \(weatherDescription.lowercased()) with a high of \(Int((maxTemp ?? 0).rounded()))°."
        content.sound = .default
        content.categoryIdentifier = Self.dailyForecastCategoryID
        
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailyForecastRequestID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling daily forecast: \(error.localizedDescription)")
            } else {
                print("✅ Daily 7 AM forecast scheduled successfully.")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate
    
    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    // Handle user's interaction with the notification (e.g., tapping an action button)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let originalContent = response.notification.request.content
        
        switch response.actionIdentifier {
            
        case "VIEW_DETAILS", "VIEW_FORECAST":
            // This logic is fine. It tells the UI to navigate to a specific screen.
            NotificationCenter.default.post(name: NSNotification.Name("ShowWeatherDetails"), object: nil, userInfo: originalContent.userInfo)
            
        case "SNOOZE":
            // BUG FIX: Correctly reschedule the notification for 30 minutes later.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
            // Re-use the original content for the snoozed notification.
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: originalContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request)

        default:
            // Handle the user tapping the main body of the notification
            NotificationCenter.default.post(name: NSNotification.Name("ShowWeatherDetails"), object: nil, userInfo: originalContent.userInfo)
            break
        }
        
        completionHandler()
    }
}
