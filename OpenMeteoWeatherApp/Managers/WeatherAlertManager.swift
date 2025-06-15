//
//  WeatherAlertManager.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

// In OpenMeteoWeatherApp/Managers/WeatherAlertManager.swift

import Foundation

class WeatherAlertManager {
    private let llmService = LLMService()
    private let notificationManager = NotificationManager()

    /// Checks the hourly forecast for interesting weather events and triggers a notification if one is found.
    func checkForAlerts(hourlyForecast: Hourly, locality: String?) async {
        print("DEBUG: Checking precipitation probabilities: \(hourlyForecast.precipitationProbability)")
        
        guard let interestingHourIndex = hourlyForecast.precipitationProbability.firstIndex(where: { probability in
            guard let probability = probability else { return false }
            // NEW: Print the specific value being evaluated, as you requested.
                        print("DEBUG: Evaluating probability: \(probability)%")
            return probability > 50
        }) else {
            print("No interesting weather alerts to send. No probability > 50 found.")
            return
        }

        // --- NEW: Get the time of the event and calculate the delay ---
        
        // 1. Get the date string for the interesting hour.
        let eventTimeString = hourlyForecast.time[interestingHourIndex]
        
        // 2. Convert that string to a Date object. We'll use our helper for this.
        guard let eventDate = DateHelper.date(from: eventTimeString) else {
            print("ERROR: Could not parse date for interesting weather event.")
            return
        }
        
        // 3. Calculate the time interval (in seconds) between now and the event.
        let now = Date()
        let timeIntervalUntilEvent = eventDate.timeIntervalSince(now)

        // 4. If the event is in the past or too close (e.g., less than 5 minutes away), don't schedule an alert.
        guard timeIntervalUntilEvent > (5 * 60) else {
            print("Interesting weather event is either in the past or starting too soon to alert.")
            return
        }
        
        // We now have a valid future event. Let's schedule the notification to fire at the right time.
        // Let's notify the user 1 hour before the event. If it's less than an hour away, notify immediately (after 5 seconds).
        let notificationDelay = max(5.0, timeIntervalUntilEvent - (60 * 60)) // Subtract 1 hour (3600 seconds)
        
        // --- END OF NEW LOGIC ---

        guard let weatherCode = hourlyForecast.weatherCode[interestingHourIndex],
              let temperature = hourlyForecast.temperature2M[interestingHourIndex] else { return }
        
        let eventDescription = createEventSummary(
            weatherCode: weatherCode,
            temperature: temperature,
            locality: locality,
            eventDate: eventDate // Pass the date for a more specific summary
        )
        
        print("Interesting weather found: \(eventDescription). Asking LLM for alert text...")
        
        do {
            let llmResponse = try await llmService.generateWeatherAlert(for: eventDescription)
            
            let components = llmResponse.split(separator: "|").map { String($0) }
            guard components.count == 2 else {
                // ... (your fallback logic is unchanged)
                return
            }
            
            let title = components[0]
            let body = components[1]
            
            // --- UPDATED NOTIFICATION CALL ---
            // We now pass the calculated delay to a modified scheduling function.
            notificationManager.scheduleWeatherAlert(title: title, body: body, timeInterval: notificationDelay)
            print("✅ Successfully scheduled LLM-generated weather alert to fire in \(Int(notificationDelay/60)) minutes.")
            
        } catch {
            print("❌ Failed to generate or schedule weather alert: \(error)")
        }
    }
    
    // Updated to be more specific
    private func createEventSummary(weatherCode: Int, temperature: Double, locality: String?, eventDate: Date) -> String {
        let condition = WeatherCodeMapper.description(for: weatherCode).lowercased()
        let temp = Int(temperature.rounded())
        let location = locality != nil ? "in \(locality!)" : "in your area"
        let time = eventDate.formatted(date: .omitted, time: .shortened)
        
        return "Upcoming weather event \(location) at around \(time): \(condition) with a temperature of \(temp)°C."
    }
}
