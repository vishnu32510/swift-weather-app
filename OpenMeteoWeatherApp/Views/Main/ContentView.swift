//
//  ContentView.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/14/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var llmService = LLMService()
    @StateObject private var weatherService = WeatherService()
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var hasScheduledDailyNotification = false
    @State private var suggestion: String?
    @State private var isLoadingSuggestion = false
    
    private var isNight: Bool {
        weatherService.currentWeather?.isDay == 0
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundView(isNight: isNight)
                ScrollView(.vertical){
                    VStack{
                        if weatherService.isLoading {
                            LoadingView()
                        }
                        else if let currentWeather = weatherService.currentWeather {
                            TodayWeather(
                                current: currentWeather,
                                locality: locationManager.placemark?.locality ?? "Unknown Location",
                            )
                            if let _ = weatherService.currentWeather {
                                if isLoadingSuggestion {
                                    ProgressView().tint(.white)
                                }
                                
                                if let suggestion = suggestion {
                                    SuggestionView(suggestionText: suggestion)
                                    Spacer()
                                }
                            }
                            
                            if let hourly = weatherService.hourlyForecast {
                                VStack(alignment: .leading){
                                    Text("HOURLY FORECAST")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.leading)
                                    
                                    NavigationLink(destination: HourlyGraphView(hourlyData: hourly)) {
                                        HourlyForecastView(hourlyData: hourly)
                                    } .buttonStyle(.plain)
                                }
                            }
                            
                            if let daily = weatherService.dailyForecast,
                               let todaySunrise = daily.sunrise.first,
                               let todaySunset = daily.sunset.first {
                                
                                SunriseSunsetView(sunriseTime: todaySunrise, sunsetTime: todaySunset)
                                
                                DailyForeCasteListView(daily: daily)
                            }
                        }else if let error = weatherService.error {
                            ErrorView(error: error)
                        } else {
                            Text("Fetching your location...")
                                .foregroundColor(.white)
                                .padding(.top, 100)
                        }
                        
                        Spacer()
                    }
                }.scrollIndicators(.hidden)
            }
            .onAppear {
                locationManager.requestLocation()
                notificationManager.requestAuthorization()
            }
            .onChange(of: locationManager.location) { oldLocation, newLocation in
                guard let location = newLocation else { return }
                
                Task {
                    await weatherService.fetchWeatherData(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
            .onChange(of: weatherService.fetchID) {
                print("--- TRACE 1: onChange(of: fetchID) was triggered. ---")
                
                if let daily = weatherService.dailyForecast, !hasScheduledDailyNotification {
                    notificationManager.scheduleDailyForecast(dailyForecast: daily)
                    hasScheduledDailyNotification = true
                }
                
                guard !isLoadingSuggestion else {
                    print("--- TRACE X: Aborted because a suggestion is already loading. ---")
                    return
                }
                print("--- TRACE 2: Starting AI suggestion Task. ---")
                Task {
                    await MainActor.run {
                        isLoadingSuggestion = true
                        suggestion = nil
                    }
                    
                    guard let current = weatherService.currentWeather,
                          let daily = weatherService.dailyForecast else {
                        print("Background task failed: Could not get weather data.")
                        return
                    }
                    
                    guard let summary = WeatherAppHelpers.create(
                        current: current,
                        daily: daily,
                        locality: locationManager.placemark?.locality
                    ) else {
                        print("Background task failed: Could not create summary.")
                        return
                    }
                    
                    guard summary != "Weather data is not currently available." else {
                        print("--- TRACE X: Aborted because weather summary could not be created. ---")
                        await MainActor.run { isLoadingSuggestion = false }
                        return
                    }
                    
                    print("--- TRACE 4: Weather summary created. Calling LLM service... ---")
                    do {
                        let fetchedSuggestion = try await llmService.fetchSuggestions(for: summary)
                        await MainActor.run {
                            self.suggestion = fetchedSuggestion
                            print("--- TRACE 5: LLM service returned successfully! ---")
                        }
                    } catch {
                        print("--- TRACE X: LLM service FAILED with error: \(error) ---")
                        await MainActor.run { self.suggestion = nil }
                    }
                    
                    await MainActor.run { isLoadingSuggestion = false }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

