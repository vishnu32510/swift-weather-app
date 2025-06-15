import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    


    static let weatherAlertCategoryID = "WEATHER_ALERT"
    static let dailyForecastCategoryID = "DAILY_FORECAST"
    static let dailyForecastRequestID = "DAILY_MORNING_FORECAST"

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
        let weatherAlertCategory = UNNotificationCategory(
            identifier: Self.weatherAlertCategoryID,
            actions: [
                UNNotificationAction(identifier: "VIEW_DETAILS", title: "View Details", options: .foreground),
            
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
    

    
    
    func scheduleWeatherAlert(title: String, body: String,timeInterval: TimeInterval = 5, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = Self.weatherAlertCategoryID
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    
    func scheduleDailyForecast(dailyForecast: Daily) {
    
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.dailyForecastRequestID])
        
    
        guard let maxTemp = dailyForecast.temperature2MMax.first,
              let weatherCode = dailyForecast.weatherCode.first else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Today's Forecast"
        
    
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


    

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let originalContent = response.notification.request.content
        
        switch response.actionIdentifier {
            
        case "VIEW_DETAILS", "VIEW_FORECAST":
        
            NotificationCenter.default.post(name: NSNotification.Name("ShowWeatherDetails"), object: nil, userInfo: originalContent.userInfo)
            
        case "SNOOZE":
        
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: originalContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request)

        default:
        
            NotificationCenter.default.post(name: NSNotification.Name("ShowWeatherDetails"), object: nil, userInfo: originalContent.userInfo)
            break
        }
        
        completionHandler()
    }
}
