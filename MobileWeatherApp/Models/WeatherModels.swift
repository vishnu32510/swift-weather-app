//
//  WeatherModels.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import Foundation

// Top-level response structure from Open-Meteo API.
struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let generationtime_ms: Double
    let utc_offset_seconds: Int
    let timezone: String
    let timezone_abbreviation: String
    let elevation: Double
    // Retaining current_weather for simplified access when available,
    // and 'current' for more detailed current hourly parameters.
    let current_weather_units: CurrentWeatherUnits? // Added to match API response
    let current_weather: CurrentWeatherAPIObject? // Simplified object from current_weather=true
    let current: CurrentParametersContainer? // Detailed current parameters (arrays)
    let daily_units: DailyUnits?
    let daily: DailyWeatherContainer?
    let hourly_units: HourlyUnits?
    let hourly: HourlyWeatherContainer?
}

// Represents the units for current_weather data.
struct CurrentWeatherUnits: Codable {
    let time: String
    let interval: String
    let temperature: String
    let windspeed: String
    let winddirection: String
    let is_day: String
    let weathercode: String
}

// Represents the simplified 'current_weather' object from the API.
struct CurrentWeatherAPIObject: Codable {
    let temperature: Double
    let windspeed: Double
    let winddirection: Double
    let weathercode: Int
    let time: String // Time as ISO 8601 string
    let is_day: Int? // Added this, based on the provided JSON
}

// Structure for current weather data used within the app (combines data if needed).
// Conforms to Equatable for use with onChange.
struct CurrentWeather: Codable, Equatable {
    let temperature: Double
    let windspeed: Double
    let winddirection: Double
    let weathercode: Int
    let time: String // Time as ISO 8601 string

    // Additional fields, potentially from 'current' detailed parameters.
    let is_day: Int? // 0 = night, 1 = day
    let relativehumidity_2m: Double?
    let apparent_temperature: Double?
    let cloudcover: Double?
}

// Structure for daily units (e.g., °C, km/h).
struct DailyUnits: Codable {
    let time: String
    let weathercode: String
    let temperature_2m_max: String
    let temperature_2m_min: String
    let precipitation_sum: String?
    let windspeed_10m_max: String?
}

// Container for daily weather data, where each property is an array of values.
struct DailyWeatherContainer: Codable {
    let time: [String] // Array of ISO 8601 date strings
    let weathercode: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let precipitation_sum: [Double]?
    let windspeed_10m_max: [Double]?
}

// A more convenient structure to represent a single day's forecast.
// This will be created by combining data from DailyWeatherContainer.
// Conforms to Equatable for use with onChange.
struct DailyWeather: Identifiable, Equatable {
    let id = UUID()
    let time: Date
    let weathercode: [Int] // Could be one code, but sometimes array is returned for period
    let temperature_2m_max: Double
    let temperature_2m_min: Double
    let precipitation_sum: Double?
    let windspeed_10m_max: Double?

    // Custom Equatable conformance for DailyWeather
    static func == (lhs: DailyWeather, rhs: DailyWeather) -> Bool {
        lhs.time == rhs.time &&
        lhs.weathercode == rhs.weathercode &&
        lhs.temperature_2m_max == rhs.temperature_2m_max &&
        lhs.temperature_2m_min == rhs.temperature_2m_min &&
        lhs.precipitation_sum == rhs.precipitation_sum &&
        lhs.windspeed_10m_max == rhs.windspeed_10m_max
    }
}

// Structure for current parameters when requested explicitly (e.g., current=temperature_2m)
// Contains arrays for each parameter.
struct CurrentParametersContainer: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let relativehumidity_2m: [Double]
    let apparent_temperature: [Double]
    let is_day: [Int]?
    let precipitation: [Double]?
    let weathercode: [Int]
    let windspeed_10m: [Double]
    let cloudcover: [Double]?
}

// Structure for hourly units.
struct HourlyUnits: Codable {
    let time: String
    let temperature_2m: String
    let relativehumidity_2m: String
    let apparent_temperature: String
    let precipitation_probability: String
    let weathercode: String
    let cloudcover: String
    let windspeed_10m: String
}

// Container for hourly weather data.
struct HourlyWeatherContainer: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let relativehumidity_2m: [Double]
    let apparent_temperature: [Double]
    let precipitation_probability: [Int]
    let weathercode: [Int]
    let cloudcover: [Double]
    let windspeed_10m: [Double]
}

// A more convenient structure to represent a single hour's forecast.
struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: Date
    let temperature_2m: Double
    let relativehumidity_2m: Double
    let apparent_temperature: Double
    let precipitation_probability: Int
    let weathercode: Int
    let cloudcover: Double
    let windspeed_10m: Double
}
