//
//  WeatherCodeMapper.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import Foundation

struct WeatherCodeMapper {
    // Maps WMO codes to SF Symbols for weather icons.
    static func symbol(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill" // Clear sky
        case 1, 2, 3: return "cloud.sun.fill" // Mainly clear, partly cloudy, overcast
        case 45, 48: return "cloud.fog.fill" // Fog, depositing rime fog
        case 51, 53, 55: return "cloud.drizzle.fill" // Drizzle: Light, moderate, and dense intensity
        case 56, 57: return "cloud.sleet.fill" // Freezing Drizzle: Light and dense intensity
        case 61, 63, 65: return "cloud.rain.fill" // Rain: Slight, moderate and heavy intensity
        case 66, 67: return "cloud.heavyrain.fill" // Freezing Rain: Light and heavy intensity
        case 71, 73, 75: return "cloud.snow.fill" // Snow fall: Slight, moderate, and heavy intensity
        case 77: return "cloud.hail.fill" // Snow grains
        case 80, 81, 82: return "cloud.bolt.rain.fill" // Rain showers: Slight, moderate, and violent
        case 85, 86: return "cloud.snow.fill" // Snow showers slight and heavy
        case 95: return "cloud.bolt.fill" // Thunderstorm: Slight or moderate
        case 96, 99: return "cloud.bolt.fill" // Thunderstorm with slight and heavy hail
        default: return "questionmark.circle.fill" // Unknown code
        }
    }

    // Maps WMO codes to human-readable descriptions.
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Fog"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snow fall"
        case 73: return "Moderate snow fall"
        case 75: return "Heavy snow fall"
        case 77: return "Snow grains"
        case 80: return "Slight rain showers"
        case 81: return "Moderate rain showers"
        case 82: return "Violent rain showers"
        case 85: return "Slight snow showers"
        case 86: return "Heavy snow showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown weather condition"
        }
    }
}

// Extension to easily check if a weather code array contains rain-related codes.
extension Array where Element == Int {
    func containsRainRelated() -> Bool {
        // WMO codes 51-67, 80-82, 96, 99 are rain/precipitation related
        let rainCodes = Set([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 96, 99])
        return self.contains(where: { rainCodes.contains($0) })
    }
}
