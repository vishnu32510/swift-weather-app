import Foundation

struct DailyForecast: Codable, Identifiable {
    let id = UUID()
    let time: Date
    let temperature_2m_max: Double
    let temperature_2m_min: Double
    let weathercode: [Int]
    let precipitation_probability_max: Int?
    let windspeed_10m_max: Double?
    let winddirection_10m_dominant: Int?
    
    init(
        time: Date,
        temperature_2m_max: Double,
        temperature_2m_min: Double,
        weathercode: [Int],
        precipitation_probability_max: Int? = nil,
        windspeed_10m_max: Double? = nil,
        winddirection_10m_dominant: Int? = nil
    ) {
        self.time = time
        self.temperature_2m_max = temperature_2m_max
        self.temperature_2m_min = temperature_2m_min
        self.weathercode = weathercode
        self.precipitation_probability_max = precipitation_probability_max
        self.windspeed_10m_max = windspeed_10m_max
        self.winddirection_10m_dominant = winddirection_10m_dominant
    }
} 