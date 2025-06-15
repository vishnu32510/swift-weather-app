import Foundation
import BackgroundTasks

@MainActor
class BackgroundTaskManager {
    // Use the same identifier you used in Info.plist
    let taskIdentifier = "com.vishnu.OpenMeteoWeatherApp.fetchWeatherSuggestion"
    
    // These are needed to perform the work
    private let locationManager = LocationManager()
    private let weatherService = WeatherService()
    private let llmService = LLMService()
    private let notificationManager = NotificationManager()
    
    // MARK: - Task Registration and Scheduling
    
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
    
    // MARK: - Task Implementation
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Schedule the next refresh immediately
        
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
            // 1. Get Location
            guard let location = locationManager.location else {
                print("Background task failed: No location.")
                return
            }
            
            // 2. Fetch Weather
            await weatherService.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            // 3. Create Summary for AI
            guard let current = weatherService.currentWeather,
                  let daily = weatherService.dailyForecast else {
                print("Background task failed: Could not get weather data.")
                return
            }
            
            // --- UPDATED CALL ---
            // Call the new, centralized summarizer.
            guard let summary = WeatherAppHelpers.create(
                current: current,
                daily: daily,
                locality: locationManager.placemark?.locality
            ) else {
                print("Background task failed: Could not create summary.")
                return
            }
            guard summary != "Weather data is not currently available." else { return }
            
            // 4. Fetch Suggestion from AI
            let suggestion = try await llmService.fetchSuggestions(for: summary)
            
            // 5. Send Notification with the suggestion
            notificationManager.scheduleWeatherAlert(
                title: "Daily Weather Tip",
                body: suggestion
            )
            print("--- Background Fetch and Notification Complete ---")
            
        } catch {
            print("Background task failed with error: \(error)")
        }
    }
    
    // --- FIX 1: Added the `locality` parameter back to the function definition. ---
    private func createWeatherSummary(locality: String?) -> String {
        guard let current = weatherService.currentWeather,
              let daily = weatherService.dailyForecast,
              let todayMaxOptional = daily.temperature2MMax.first, let todayMax = todayMaxOptional,
              let todayMinOptional = daily.temperature2MMin.first, let todayMin = todayMinOptional else {
            return "Weather data is not currently available."
        }
        
        let description = WeatherCodeMapper.description(for: current.weatherCode)
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "E, MMM d, h:mm a"
        let currentTimeString = timeFormatter.string(from: now)
        
        let summary = """
            Here is a summary of the current weather in \(locality ?? "your area") as of \(currentTimeString):
            - Overall Condition: \(description)
            - Current Temperature: \(Int(current.temperature2M.rounded()))°C
            - Feels Like: \(Int(current.apparentTemperature.rounded()))°C
            - Today's High/Low: The high for today will be \(Int(todayMax.rounded()))°C and the low will be \(Int(todayMin.rounded()))°C.
            - Precipitation: Current precipitation is \(current.precipitation) mm.
            - Wind: The wind is blowing from the \(windDirection(from: current.windDirection10M)) at \(Int(current.windSpeed10M.rounded())) km/h.
            - Cloud Cover: \(current.cloudCover)% of the sky is covered by clouds.
            - Humidity: The relative humidity is \(current.relativeHumidity2M)%.
            """
        
        return summary
    }
    
    // --- FIX 2: Added the missing helper function so it's in scope. ---
    private func windDirection(from degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(degrees) + 11.25) / 22.5) & 15
        return directions[index]
    }
}
