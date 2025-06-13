//
//  WeatherDisplayView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI
import CoreLocation

struct WeatherDisplayView: View {
    let location: CLLocation
    @EnvironmentObject private var weatherService: WeatherService
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 20) {
            if weatherService.isLoading {
                ProgressView("Fetching weather...")
            } else if let weather = weatherService.currentWeather {
                // Current weather display
                Text(locationManager.placemark?.locality ?? "Your Location")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text(WeatherCodeMapper.description(for: weather.weathercode))
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)

                HStack(spacing: 15) {
                    Image(systemName: WeatherCodeMapper.symbol(for: weather.weathercode))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)

                    Text("\(Int(weather.temperature))°C")
                        .font(.system(size: 80, weight: .bold))
                        .gradientForeground(colors: [Color.blue, Color.purple])
                }
                .padding(.bottom, 20)

                // Additional weather details
                VStack(alignment: .leading, spacing: 10) {
                    WeatherDetailRow(icon: "wind", label: "Wind Speed", value: "\(Int(weather.windspeed)) km/h")
                    WeatherDetailRow(icon: "cloud", label: "Cloud Cover", value: "\(Int(weather.cloudcover ?? 0))%")
                    WeatherDetailRow(icon: "humidity", label: "Humidity", value: "\(Int(weather.relativehumidity_2m ?? 0))%")
                    WeatherDetailRow(icon: "thermometer.sun", label: "Feels Like", value: "\(Int(weather.apparent_temperature ?? 0))°C")
                }
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))
                .shadow(radius: 5)
                .padding(.bottom, 30)

                // Navigation Link to ForecastView
                NavigationLink {
                    ForecastView()
                        .environmentObject(weatherService)
                } label: {
                    Label("View 7-Day Forecast", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)

            } else if let error = weatherService.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Text("No weather data available. Please enable location services.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            Task {
                await weatherService.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
    }
}

// Custom ViewModifier for gradient text
extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                gradient: .init(colors: colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(self)
        )
    }
}

// Helper view for displaying a single detail row
struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
