import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
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
        // Weather alert category
        let weatherAlertCategory = UNNotificationCategory(
            identifier: "WEATHER_ALERT",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Snooze",
                    options: .authenticationRequired
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        // Daily forecast category
        let dailyForecastCategory = UNNotificationCategory(
            identifier: "DAILY_FORECAST",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_FORECAST",
                    title: "View Forecast",
                    options: .foreground
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            weatherAlertCategory,
            dailyForecastCategory
        ])
    }
    
    func scheduleWeatherAlert(title: String, body: String, weatherCode: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "WEATHER_ALERT"
        content.userInfo = ["weatherCode": weatherCode]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyForecast(forecast: [DailyWeather]) {
        // Remove any existing forecast notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new forecast notification for 7 AM
        let content = UNMutableNotificationContent()
        content.title = "Today's Weather Forecast"
        
        if let todayForecast = forecast.first {
            let weatherDescription = WeatherCodeMapper.description(for: todayForecast.weathercode.first ?? 0)
            content.body = "\(weatherDescription) with a high of \(Int(todayForecast.temperature_2m_max))°C"
        }
        
        content.sound = .default
        content.categoryIdentifier = "DAILY_FORECAST"
        
        // Create date components for 7 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "DAILY_FORECAST",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "VIEW_DETAILS", "VIEW_FORECAST":
            // Handle navigation to weather details
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowWeatherDetails"),
                object: nil,
                userInfo: userInfo
            )
        case "SNOOZE":
            // Reschedule the notification for 30 minutes later
            if let weatherCode = userInfo["weatherCode"] as? Int {
                scheduleWeatherAlert(
                    title: "Weather Alert Reminder",
                    body: "Don't forget to check the weather conditions!",
                    weatherCode: weatherCode
                )
            }
        default:
            break
        }
        
        completionHandler()
    }
} 