//
//  LocationAccessPromptView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI
import CoreLocationUI

struct LocationAccessPromptView: View {
    // Environment object to access the LocationManager and request location.
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("Allow Location Access")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("This app needs your location to provide accurate weather forecasts. Please enable location services.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            LocationButton(.shareCurrentLocation) {
                locationManager.requestLocation() // Request location when button is tapped.
            }
            .symbolVariant(.fill)
            .labelStyle(.titleAndIcon)
            .cornerRadius(10)
            .tint(.blue)
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    LocationAccessPromptView()
        .environmentObject(LocationManager())
}
