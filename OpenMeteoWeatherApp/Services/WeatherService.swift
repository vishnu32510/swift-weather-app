import Foundation
import SwiftUI

@MainActor
class WeatherService: ObservableObject {
    @Published var currentWeather: Current?
    @Published var hourlyForecast: Hourly?
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
            
                throw WeatherServiceError.networkError(statusCode: -1)
            }

        
            switch httpResponse.statusCode {
                
            case 200:
            
                let decoder = JSONDecoder()
            
                let weatherResponse = try decoder.decode(WeatherResponseModel.self, from: data)
                
            
                self.processWeatherResponse(weatherResponse)
                currentRetryCount = 0

            case 429:
            
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                
                    let sleepDuration = UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: sleepDuration)
                    await fetchWeatherData(latitude: latitude, longitude: longitude)
                } else {
                    throw WeatherServiceError.rateLimitExceeded
                }

            case 500...599:
            
                if currentRetryCount < maxRetries {
                    currentRetryCount += 1
                    let sleepDuration = UInt64(pow(2.0, Double(currentRetryCount)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: sleepDuration)
                    await fetchWeatherData(latitude: latitude, longitude: longitude)
                } else {
                    throw WeatherServiceError.serverError(statusCode: httpResponse.statusCode)
                }

            default:
            
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
        self.hourlyForecast = response.hourly
        self.dailyForecast = response.daily
        self.fetchID = UUID()
    }
    

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
