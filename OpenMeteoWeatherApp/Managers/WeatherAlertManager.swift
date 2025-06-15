//
//  WeatherAlertManager.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//


import Foundation

class WeatherAlertManager {
    private let llmService = LLMService()
    private let notificationManager = NotificationManager()

    
    func checkForAlerts(hourlyForecast: Hourly, locality: String?) async {
        print("DEBUG: Checking precipitation probabilities: \(hourlyForecast.precipitationProbability)")
        
        guard let interestingHourIndex = hourlyForecast.precipitationProbability.firstIndex(where: { probability in
            guard let probability = probability else { return false }
        
                        print("DEBUG: Evaluating probability: \(probability)%")
            return probability > 50
        }) else {
            print("No interesting weather alerts to send. No probability > 50 found.")
            return
        }

    
        
    
        let eventTimeString = hourlyForecast.time[interestingHourIndex]
        
    
        guard let eventDate = DateHelper.date(from: eventTimeString) else {
            print("ERROR: Could not parse date for interesting weather event.")
            return
        }
        
    
        let now = Date()
        let timeIntervalUntilEvent = eventDate.timeIntervalSince(now)

    
        guard timeIntervalUntilEvent > (5 * 60) else {
            print("Interesting weather event is either in the past or starting too soon to alert.")
            return
        }
        
    
    
        let notificationDelay = max(5.0, timeIntervalUntilEvent - (60 * 60))
        
    

        guard let weatherCode = hourlyForecast.weatherCode[interestingHourIndex],
              let temperature = hourlyForecast.temperature2M[interestingHourIndex] else { return }
        
        let eventDescription = createEventSummary(
            weatherCode: weatherCode,
            temperature: temperature,
            locality: locality,
            eventDate: eventDate
        )
        
        print("Interesting weather found: \(eventDescription). Asking LLM for alert text...")
        
        do {
            let llmResponse = try await llmService.generateWeatherAlert(for: eventDescription)
            
            let components = llmResponse.split(separator: "|").map { String($0) }
            guard components.count == 2 else {
            
                return
            }
            
            let title = components[0]
            let body = components[1]
            
        
        
            notificationManager.scheduleWeatherAlert(title: title, body: body, timeInterval: notificationDelay)
            print("✅ Successfully scheduled LLM-generated weather alert to fire in \(Int(notificationDelay/60)) minutes.")
            
        } catch {
            print("❌ Failed to generate or schedule weather alert: \(error)")
        }
    }
    

    private func createEventSummary(weatherCode: Int, temperature: Double, locality: String?, eventDate: Date) -> String {
        let condition = WeatherCodeMapper.description(for: weatherCode).lowercased()
        let temp = Int(temperature.rounded())
        let location = locality != nil ? "in \(locality!)" : "in your area"
        let time = eventDate.formatted(date: .omitted, time: .shortened)
        
        return "Upcoming weather event \(location) at around \(time): \(condition) with a temperature of \(temp)°C."
    }
}
