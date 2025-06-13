import Foundation

enum WeatherCodeMapper {
    static func symbol(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill" // Clear sky
        case 1, 2, 3: return "cloud.sun.fill" // Mainly clear, partly cloudy, overcast
        case 45, 48: return "cloud.fog.fill" // Fog and depositing rime fog
        case 51, 53, 55: return "cloud.drizzle.fill" // Drizzle
        case 56, 57: return "cloud.sleet.fill" // Freezing drizzle
        case 61, 63, 65: return "cloud.rain.fill" // Rain
        case 66, 67: return "cloud.sleet.fill" // Freezing rain
        case 71, 73, 75: return "cloud.snow.fill" // Snow fall
        case 77: return "cloud.snow.fill" // Snow grains
        case 80, 81, 82: return "cloud.rain.fill" // Rain showers
        case 85, 86: return "cloud.snow.fill" // Snow showers
        case 95: return "cloud.bolt.fill" // Thunderstorm
        case 96, 99: return "cloud.bolt.rain.fill" // Thunderstorm with hail
        default: return "cloud.fill"
        }
    }
    
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 56, 57: return "Freezing drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow grains"
        case 80, 81, 82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm with hail"
        default: return "Unknown"
        }
    }
} 