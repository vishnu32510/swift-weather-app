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
    // State object for managing location services.
    // This allows the view to observe changes in the user's location.
    @StateObject private var locationManager = LocationManager()
    // State object for managing weather data.
    // This allows the view to observe and react to fetched weather updates.
    @StateObject private var weatherService = WeatherService()
    // Environment object for notification management, injected from MobileWeatherAppApp.
    @EnvironmentObject private var notificationManager: NotificationManager

    // State variable to control the visibility of the settings sheet.
    @State private var showingSettingsSheet = false

    var body: some View {
        NavigationView { // Enables navigation between different views.
            VStack {
                // Delegating the complex conditional rendering to a helper view
                LocationBasedWeatherView()
                    .environmentObject(locationManager) // Pass locationManager to the helper
                    .environmentObject(weatherService)  // Pass weatherService to the helper
            }
            .navigationTitle("Weather Assistant") // Title for the navigation bar.
            .toolbar { // Toolbar items for navigation and actions.
                ToolbarItem(placement: .navigationBarLeading) {
                    // Button to refresh weather data (if location is available).
                    Button {
                        if let loc = locationManager.location {
                            // Call async fetchWeatherData in a Task
                            Task {
                                await weatherService.fetchWeatherData(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                            }
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Button to present the SettingsView sheet.
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            // Sheet for displaying settings.
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
                    .environmentObject(notificationManager) // Pass notificationManager to SettingsView.
            }
            .onAppear {
                // Request notification authorization when the view appears.
                notificationManager.requestAuthorization()
            }
            // Observe changes in location and fetch weather data accordingly.
            .onChange(of: locationManager.location) { newLocation in
                if let newLocation = newLocation {
                    // Call async fetchWeatherData in a Task
                    Task {
                        await weatherService.fetchWeatherData(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                    }
                }
            }
            // Observe changes in weather data and potentially schedule notifications.
            // CurrentWeather now conforms to Equatable.
            .onChange(of: weatherService.currentWeather) { newWeather in
                if let newWeather = newWeather {
                    // Example: Schedule a notification if temperature is low.
                    // You can add more complex logic here (e.g., precipitation alerts).
                    if newWeather.temperature < 5.0 && notificationManager.notificationsEnabled {
                        notificationManager.scheduleNotification(
                            title: "Temperature Alert!",
                            body: "It's getting chilly! Current temperature is \(String(format: "%.1f", newWeather.temperature))°C. Dress warmly!",
                            sound: .default
                        )
                    }
                }
            }
            // Observe changes in forecast data and potentially schedule notifications.
            // DailyWeather now conforms to Equatable, allowing for array comparison.
            .onChange(of: weatherService.dailyForecast) { newForecast in
                // Example: Schedule a notification if rain is predicted for tomorrow.
                if let tomorrowForecast = newForecast?.first,
                   tomorrowForecast.weathercode.containsRainRelated() && notificationManager.notificationsEnabled {
                    notificationManager.scheduleNotification(
                        title: "Tomorrow's Weather!",
                        body: "Rain is expected tomorrow. Don't forget your umbrella!",
                        sound: .default,
                        triggerDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
