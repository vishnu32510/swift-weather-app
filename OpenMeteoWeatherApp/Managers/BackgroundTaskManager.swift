import Foundation
import BackgroundTasks

@MainActor
class BackgroundTaskManager {

    let taskIdentifier = "com.vishnu.OpenMeteoWeatherApp.fetchWeatherSuggestion"
    

    private let locationManager = LocationManager()
    private let weatherAlertManager = WeatherAlertManager()
    private let weatherService = WeatherService()
    private let llmService = LLMService()
    private let notificationManager = NotificationManager()
    

    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 8 * 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background Task Scheduled.")
        } catch {
            print("❌ Could not schedule background task: \(error)")
        }
    }
    

    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            Task {
                await self.performBackgroundTask()
            }
        }
        
        task.expirationHandler = { operation.cancel() }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        operationQueue.addOperation(operation)
    }
    
    @MainActor
    private func performBackgroundTask() async {
        print("--- Performing Background Fetch ---")
        do {
        
            guard let location = locationManager.location else {
                print("Background task failed: No location.")
                return
            }
            
        
            await weatherService.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
        
                        if let hourly = weatherService.hourlyForecast {
                            await weatherAlertManager.checkForAlerts(
                                hourlyForecast: hourly,
                                locality: locationManager.placemark?.locality
                            )
                        }
            
        
            guard let current = weatherService.currentWeather,
                  let daily = weatherService.dailyForecast else {
                print("Background task failed: Could not get weather data.")
                return
            }
            
            guard let summary = WeatherAppHelpers.create(
                current: current,
                daily: daily,
                locality: locationManager.placemark?.locality
            ) else {
                print("Background task failed: Could not create summary.")
                return
            }
            guard summary != "Weather data is not currently available." else { return }
            
        
            let suggestion = try await llmService.fetchSuggestions(for: summary)
            
        
            notificationManager.scheduleWeatherAlert(
                title: "Daily Weather Tip",
                body: suggestion
            )
            print("--- Background Fetch and Notification Complete ---")
            
        } catch {
            print("Background task failed with error: \(error)")
        }
    }

}
