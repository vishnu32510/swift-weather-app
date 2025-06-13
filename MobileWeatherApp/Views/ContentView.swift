//
//  ContentView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI
import CoreLocationUI // Required for LocationButton
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var isNight = false
    
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        ZStack {
            BackgroundView(isNight: $isNight)
            
            VStack {
                CityView(cityName: locationManager.placemark?.locality ?? "Your Location")
                
                TodayWeather(
                    imageName: isNight ? "moon.stars.fill" : "sun.max.fill",
                    temperature: Int(weatherService.currentWeather?.temperature ?? 0)
                )
                
                HStack(spacing: 20) {
                    if let dailyForecast = weatherService.dailyForecast {
                        ForEach(dailyForecast) { day in
                            WeatherDayView(
                                dayOfWeek: formatDayOfWeek(day.time),
                                imageName: WeatherCodeMapper.symbol(for: day.weathercode.first ?? 0),
                                temperature: Int(day.temperature_2m_max)
                            )
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    isNight.toggle()
                } label: {
                    WeatherButtonView(title: "Change Day Time")
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                Task {
                    await weatherService.fetchWeatherData(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager())
}
