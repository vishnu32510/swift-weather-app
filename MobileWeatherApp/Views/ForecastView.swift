//
//  ForecastView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI

struct ForecastView: View {
    @EnvironmentObject private var weatherService: WeatherService

    var body: some View {
        VStack {
            if weatherService.isLoadingDailyForecast {
                ProgressView("Fetching forecast...")
            } else if let daily = weatherService.dailyForecast {
                List {
                    // Display each day's forecast in a section.
                    ForEach(0..<daily.count, id: \.self) { index in
                        let forecast = daily[index]
                        ForecastRow(forecast: forecast, index: index)
                    }
                }
                .listStyle(.plain) // Use plain list style for a cleaner look.
            } else if let error = weatherService.error {
                Text("Error loading forecast: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Text("No forecast data available.")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("7-Day Forecast") // Title for the navigation bar.
        .navigationBarTitleDisplayMode(.inline) // Keep title inline for forecast.
    }
}

struct ForecastRow: View {
    let forecast: DailyWeather
    let index: Int

    // Formatter to display the date.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d" // e.g., "Monday, Jan 1"
        return formatter
    }()

    var body: some View {
        HStack {
            // Display the date for the forecast.
            Text(index == 0 ? "Today" : dateFormatter.string(from: forecast.time))
                .font(.headline)
                .frame(width: 120, alignment: .leading)

            Spacer()

            // Weather icon based on the weather code.
            Image(systemName: WeatherCodeMapper.symbol(for: forecast.weathercode.first ?? 0)) // Take first code if multiple
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.orange)

            Spacer()

            // Weather description.
            Text(WeatherCodeMapper.description(for: forecast.weathercode.first ?? 0))
                .font(.subheadline)
                .frame(width: 100, alignment: .center)

            Spacer()

            // Min and Max temperatures.
            Text("\(Int(forecast.temperature_2m_max))° / \(Int(forecast.temperature_2m_min))°")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
}
