//
//  WeatherService.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import Foundation
import SwiftUI // For @Published

// Use @MainActor to ensure all @Published updates happen on the main thread
@MainActor
class WeatherService: ObservableObject {
    // Published properties automatically notify SwiftUI views when they change.
    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecast: [DailyWeather]?
    @Published var hourlyForecast: [HourlyWeather]?
    @Published var isLoading: Bool = false
    @Published var isLoadingDailyForecast: Bool = false
    @Published var error: Error?

    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let cache = NSCache<NSString, CachedWeatherData>()
    private let maxRetries = 3
    private var currentRetryCount = 0
    
    // Change struct to class for NSCache compatibility
    class CachedWeatherData {
        let data: WeatherResponse
        let timestamp: Date
        
        init(data: WeatherResponse, timestamp: Date) {
            self.data = data
            self.timestamp = timestamp
        }
    }
    
    private func isCacheValid(_ cachedData: CachedWeatherData) -> Bool {
        let cacheAge = Date().timeIntervalSince(cachedData.timestamp)
        return cacheAge < 1800 // Cache valid for 30 minutes
    }
    
    // Fetches all relevant weather data (current, daily, hourly) for a given location.
    // Marked as 'async' and 'throws' for structured concurrency and error handling.
    func fetchWeatherData(latitude: Double, longitude: Double) async {
        isLoading = true
        isLoadingDailyForecast = true
        error = nil
        
        // Check cache first
        let cacheKey = "\(latitude),\(longitude)" as NSString
        if let cachedData = cache.object(forKey: cacheKey),
           isCacheValid(cachedData) {
            self.processWeatherResponse(cachedData.data)
            return
        }

        // Construct the URL with all necessary parameters for current, daily, and hourly data.
        guard var urlComponents = URLComponents(string: baseURL) else {
            self.error = WeatherServiceError.invalidURL
            self.isLoading = false
            self.isLoadingDailyForecast = false
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current_weather", value: "true"), // Request the simplified current_weather object
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "windspeed_unit", value: "kmh"),
            URLQueryItem(name: "precipitation_unit", value: "mm"),
            URLQueryItem(name: "timezone", value: TimeZone.current.identifier), // Use device's timezone
            // Requesting all daily parameters for the forecast view
            URLQueryItem(name: "daily", value: "weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,windspeed_10m_max"),
            // Requesting all current parameters needed for display.
            // These will be in the 'current' object (CurrentParametersContainer) in the response.
            // Although not strictly used for populating `CurrentWeather` if `current_weather` is present,
            // they are kept for the `hourly` data which is used for notifications.
            URLQueryItem(name: "current", value: "temperature_2m,relativehumidity_2m,apparent_temperature,is_day,precipitation,weathercode,windspeed_10m,cloudcover"),
            // Requesting hourly parameters (optional, but good for future features)
            URLQueryItem(name: "hourly", value: "temperature_2m,relativehumidity_2m,apparent_temperature,precipitation_probability,weathercode,cloudcover,windspeed_10m")
        ]

        guard let url = urlComponents.url else {
            self.error = WeatherServiceError.invalidURL
            self.isLoading = false
            self.isLoadingDailyForecast = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.networkError(statusCode: -1)
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                // Cache the successful response
                let cachedData = CachedWeatherData(data: weatherResponse, timestamp: Date())
                cache.setObject(cachedData, forKey: cacheKey)
                
                self.processWeatherResponse(weatherResponse)
                currentRetryCount = 0 // Reset retry count on success
                
            case 429: // Rate limit
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000))
                    await fetchWeatherData(latitude: latitude, longitude: longitude)
                } else {
                    throw WeatherServiceError.rateLimitExceeded
                }
                
            case 500...599:
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000))
                    await fetchWeatherData(latitude: latitude, longitude: longitude)
                } else {
                    throw WeatherServiceError.serverError(statusCode: httpResponse.statusCode)
                }
                
            default:
                throw WeatherServiceError.networkError(statusCode: httpResponse.statusCode)
            }
        } catch {
            self.error = error
            print("WeatherService Error: \(error.localizedDescription)")
        }
        
        self.isLoading = false
        self.isLoadingDailyForecast = false
    }
    
    private func processWeatherResponse(_ response: WeatherResponse) {
        // Process current weather
        if let currentParams = response.current_weather {
            self.currentWeather = CurrentWeather(
                temperature: currentParams.temperature,
                windspeed: currentParams.windspeed,
                winddirection: currentParams.winddirection,
                weathercode: currentParams.weathercode,
                time: currentParams.time,
                is_day: currentParams.is_day,
                relativehumidity_2m: nil,
                apparent_temperature: nil,
                cloudcover: nil
            )
        }
        
        // Process hourly forecast
        if let hourlyContainer = response.hourly {
            var hourlyForecasts: [HourlyWeather] = []
            for i in 0..<hourlyContainer.time.count {
                if let date = ISO8601DateFormatter().date(from: hourlyContainer.time[i]) {
                    let hourly = HourlyWeather(
                        time: date,
                        temperature_2m: hourlyContainer.temperature_2m[i],
                        relativehumidity_2m: hourlyContainer.relativehumidity_2m[i],
                        apparent_temperature: hourlyContainer.apparent_temperature[i],
                        precipitation_probability: hourlyContainer.precipitation_probability[i],
                        weathercode: hourlyContainer.weathercode[i],
                        cloudcover: hourlyContainer.cloudcover[i],
                        windspeed_10m: hourlyContainer.windspeed_10m[i]
                    )
                    hourlyForecasts.append(hourly)
                }
            }
            self.hourlyForecast = hourlyForecasts
        }
        
        // Process daily forecast
        if let dailyContainer = response.daily {
            var dailyForecasts: [DailyWeather] = []
            for i in 0..<dailyContainer.time.count {
                if let date = ISO8601DateFormatter().date(from: dailyContainer.time[i]) {
                    let daily = DailyWeather(
                        time: date,
                        weathercode: [dailyContainer.weathercode[i]],
                        temperature_2m_max: dailyContainer.temperature_2m_max[i],
                        temperature_2m_min: dailyContainer.temperature_2m_min[i],
                        precipitation_sum: dailyContainer.precipitation_sum?[i],
                        windspeed_10m_max: dailyContainer.windspeed_10m_max?[i]
                    )
                    dailyForecasts.append(daily)
                }
            }
            self.dailyForecast = dailyForecasts
        }
    }

    // Custom error types for WeatherService
    enum WeatherServiceError: LocalizedError {
        case invalidURL
        case noData
        case decodingError(Error)
        case networkError(statusCode: Int)
        case serverError(statusCode: Int)
        case rateLimitExceeded

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The weather API URL is invalid."
            case .noData:
                return "No weather data was received from the server."
            case .decodingError(let error):
                return "Failed to decode weather data: \(error.localizedDescription)"
            case .networkError(let statusCode):
                return "Network error with status code: \(statusCode)"
            case .serverError(let statusCode):
                return "Server error with status code: \(statusCode)"
            case .rateLimitExceeded:
                return "Too many requests. Please try again later."
            }
        }
    }
}
