//
//  LocationBasedWeatherView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI
struct LocationBasedWeatherView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherService: WeatherService // Also needs access to weatherService

    var body: some View {
        Group { // Use Group to conditionally render different views
            if locationManager.authorizationStatus == .notDetermined {
                LocationAccessPromptView()
            } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                LocationDeniedView()
            } else if let location = locationManager.location {
                WeatherDisplayView(location: location)
            } else {
                ProgressView("Getting your location...")
            }
        }
    }
}
