//
//  LocationDeniedView.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)

            Text("Location Access Denied")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Please enable location services for this app in your iPhone's Settings to get weather updates.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Open Settings") {
                // Direct the user to the app's settings to enable location.
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top, 20)
        }
        .padding()
    }
}
