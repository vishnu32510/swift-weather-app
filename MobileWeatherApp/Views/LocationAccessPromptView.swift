//
//  LocationAccessPromptView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI

struct LocationAccessPromptView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            
            switch locationManager.authorizationStatus {
            case .notDetermined:
                Text("Location Access Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Please allow location access to get weather information for your area.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Button {
                    locationManager.requestLocation()
                } label: {
                    Text("Enable Location")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
            case .restricted, .denied:
                Text("Location Access Denied")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Please enable location access in Settings to get weather information for your area.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
            default:
                if let error = locationManager.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.white)
                } else {
                    ProgressView("Getting location...")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}

#Preview {
    LocationAccessPromptView()
        .environmentObject(LocationManager())
}
