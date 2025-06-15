//
//  Helper.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import Foundation

enum WeatherAppHelpers {
    
    /// Creates a human-readable weather summary string for use with an LLM prompt.
    /// - Parameters:
    ///   - current: The `Current` weather data object.
    ///   - daily: The `Daily` forecast data object.
    ///   - locality: An optional string for the user's city name.
    /// - Returns: A formatted summary string, or `nil` if essential data is missing.
    public static func create(current: Current, daily: Daily, locality: String?) -> String? {
        
        // Use guard to safely unwrap the first day's high and low temps.
        guard let todayMaxOptional = daily.temperature2MMax.first, let todayMax = todayMaxOptional,
              let todayMinOptional = daily.temperature2MMin.first, let todayMin = todayMinOptional else {
            // Return nil if data is incomplete.
            return nil
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
    
    /// This helper function is now private to this utility.
    private static func windDirection(from degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(degrees) + 11.25) / 22.5) & 15
        return directions[index]
    }
}
