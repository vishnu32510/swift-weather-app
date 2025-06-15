import Foundation
import SwiftUI

@MainActor
class WeatherService: ObservableObject {
    @Published var currentWeather: Current?
    @Published var hourlyForecast: Hourly? // Re-enabled to match the data model
    @Published var dailyForecast: Daily?
    
    @Published var fetchID = UUID()
    
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let cache = NSCache<NSString, NSData>()
    private let maxRetries = 3
    private var currentRetryCount = 0
    
    func fetchWeatherData(latitude: Double, longitude: Double) async {
        isLoading = true
        error = nil
        
//        let cacheKey = "\(latitude),\(longitude)" as NSString
//        if let cachedData = cache.object(forKey: cacheKey) {
//            do {
//                print("✅ Loading weather data from cache.")
//                let weatherResponse = try JSONDecoder().decode(WeatherResponseModel.self, from: cachedData as Data)
//                self.processWeatherResponse(weatherResponse)
//                self.isLoading = false
//                return
//            } catch {
//                print("⚠️ Cached data is invalid. Fetching from network.")
//                cache.removeObject(forKey: cacheKey)
//            }
//        }

        guard var urlComponents = URLComponents(string: baseURL) else {
            self.error = WeatherServiceError.invalidURL
            self.isLoading = false
            return
        }

        let currentParams = "temperature_2m,relativehumidity_2m,apparent_temperature,is_day,precipitation,weathercode,cloudcover,windspeed_10m,winddirection_10m"
        let hourlyParams = "temperature_2m,relativehumidity_2m,apparent_temperature,precipitation_probability,weathercode,cloudcover,windspeed_10m,is_day"
        let dailyParams = "weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,windspeed_10m_max,precipitation_probability_max,sunrise,sunset"

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current", value: currentParams),
            URLQueryItem(name: "hourly", value: hourlyParams),
            URLQueryItem(name: "daily", value: dailyParams),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "windspeed_unit", value: "kmh"),
            URLQueryItem(name: "precipitation_unit", value: "mm"),
            URLQueryItem(name: "forecast_days", value: "16"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = urlComponents.url else {
            self.error = WeatherServiceError.invalidURL
            self.isLoading = false
            return
        }
        
        print("🌍 Fetching weather data from URL: \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("\n--- API Response ---\n\(jsonString)\n-------------------\n")
//            }

            guard let httpResponse = response as? HTTPURLResponse else {
                // We couldn't even get a HTTP response, throw a generic error.
                throw WeatherServiceError.networkError(statusCode: -1)
            }

            // --- YOUR SUPERIOR SWITCH STATEMENT IS RESTORED ---
            switch httpResponse.statusCode {
                
            case 200:
                // --- SUCCESS ---
                let decoder = JSONDecoder()
                // The fix (removing dateDecodingStrategy) is applied here
                let weatherResponse = try decoder.decode(WeatherResponseModel.self, from: data)
                
                // Cache the valid data and process the response
//                cache.setObject(data as NSData, forKey: cacheKey)
                self.processWeatherResponse(weatherResponse)
                currentRetryCount = 0 // Reset retry count on success

            case 429:
                // --- RATE LIMIT: RETRY ---
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                    // Exponential backoff: wait 2s, then 4s, then 8s...
                    let sleepDuration = UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: sleepDuration)
                    await fetchWeatherData(latitude: latitude, longitude: longitude) // Retry the request
                } else {
                    throw WeatherServiceError.rateLimitExceeded
                }

            case 500...599:
                // --- SERVER ERROR: RETRY ---
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                    let sleepDuration = UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: sleepDuration)
                    await fetchWeatherData(latitude: latitude, longitude: longitude) // Retry the request
                } else {
                    throw WeatherServiceError.serverError(statusCode: httpResponse.statusCode)
                }

            default:
                // --- ALL OTHER ERRORS ---
                throw WeatherServiceError.networkError(statusCode: httpResponse.statusCode)
            }

        } catch {
            self.error = error
            print("❌ WeatherService Error: \(error)")
        }
        
        self.isLoading = false
    }
    
    private func processWeatherResponse(_ response: WeatherResponseModel) {
        print("✅ Successfully parsed WeatherResponseModel.")
        self.currentWeather = response.current
        self.hourlyForecast = response.hourly // Re-enabled
        self.dailyForecast = response.daily
        self.fetchID = UUID()
    }
    
    // Custom error enum...
    enum WeatherServiceError: LocalizedError {
        case invalidURL
        case networkError(statusCode: Int)
        case rateLimitExceeded
        case serverError(statusCode: Int)

        var errorDescription: String? {
             switch self {
             case .invalidURL: return "The weather API URL is invalid."
             case .networkError(let statusCode): return "Network error with status code: \(statusCode). Please check your connection."
             case .rateLimitExceeded: return "Too many requests. Please try again later."
             case .serverError(let statusCode): return "Server error with status code: \(statusCode)."
             }
         }
    }
}
