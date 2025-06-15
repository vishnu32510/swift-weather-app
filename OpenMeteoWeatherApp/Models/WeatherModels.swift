import Foundation

struct WeatherResponseModel: Codable {
    let latitude, longitude: Double
    let generationtimeMS: Double
    let utcOffsetSeconds: Int
    let timezone, timezoneAbbreviation: String
    let elevation: Int
    let currentUnits: CurrentUnits
    let current: Current
    let hourlyUnits: HourlyUnits
    let hourly: Hourly
    let dailyUnits: DailyUnits
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
        case hourlyUnits = "hourly_units"
        case hourly
        case dailyUnits = "daily_units"
        case daily
    }
}

struct Current: Codable, Equatable {
    let time: String
    let interval: Int
    let temperature2M: Double
    let relativeHumidity2M: Int
    let apparentTemperature: Double
    let isDay: Int
    let precipitation: Double
    let weatherCode: Int
    let cloudCover: Int
    let windSpeed10M: Double
    let windDirection10M: Int

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relativehumidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation
        case weatherCode = "weathercode"
        case cloudCover = "cloudcover"
        case windSpeed10M = "windspeed_10m"
        case windDirection10M = "winddirection_10m"
    }
}

struct CurrentUnits: Codable {
    let time, interval, temperature2M, relativeHumidity2M, apparentTemperature, isDay, precipitation, weatherCode, cloudCover, windSpeed10M, windDirection10M: String
    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relativehumidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation
        case weatherCode = "weathercode"
        case cloudCover = "cloudcover"
        case windSpeed10M = "windspeed_10m"
        case windDirection10M = "winddirection_10m"
    }
}

struct Daily: Codable, Equatable {
    let time: [String]
    let weatherCode: [Int?]
    let temperature2MMax, temperature2MMin: [Double?]
    let precipitationSum: [Double?]
    let windSpeed10MMax: [Double?]
    let precipitationProbabilityMax: [Int?]
    let sunrise: [String]
    let sunset: [String]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weathercode"
        case temperature2MMax = "temperature_2m_max"
        case temperature2MMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case windSpeed10MMax = "windspeed_10m_max"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case sunrise = "sunrise"
        case sunset = "sunset"
    }
}

struct DailyUnits: Codable {
    let time, weatherCode, temperature2MMax, temperature2MMin, precipitationSum, windSpeed10MMax: String
    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weathercode"
        case temperature2MMax = "temperature_2m_max"
        case temperature2MMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case windSpeed10MMax = "windspeed_10m_max"
    }
}

struct Hourly: Codable, Equatable {
    let time: [String]
    let temperature2M: [Double?]
    let relativeHumidity2M: [Int?]
    let apparentTemperature: [Double?]
    let precipitationProbability: [Int?]
    let weatherCode: [Int?]
    let cloudCover: [Int?]
    let windSpeed10M: [Double?]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relativehumidity_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weathercode"
        case cloudCover = "cloudcover"
        case windSpeed10M = "windspeed_10m"
    }
}

struct HourlyUnits: Codable {
    let time, temperature2M, relativeHumidity2M, apparentTemperature, precipitationProbability, weatherCode, cloudCover, windSpeed10M: String
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relativehumidity_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weathercode"
        case cloudCover = "cloudcover"
        case windSpeed10M = "windspeed_10m"
    }
}
