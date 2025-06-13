import SwiftUI
import CoreLocation

// Helper view to handle location-based conditional rendering
struct LocationBasedWeatherView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var weatherService: WeatherService

    var body: some View {
        Group {
            if locationManager.authorizationStatus == .notDetermined {
                // Prompt for location permission if not yet determined.
                LocationAccessPromptView()
            } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                // Inform the user if location access is denied or restricted.
                LocationDeniedView()
            } else if let location = locationManager.location {
                // Display weather data if location is available.
                WeatherDisplayView(location: location)
            } else {
                // Show a loading or waiting message if location is being acquired.
                ProgressView("Getting your location...")
            }
        }
    }
}

#Preview {
    LocationBasedWeatherView()
        .environmentObject(LocationManager())
        .environmentObject(WeatherService())
} 