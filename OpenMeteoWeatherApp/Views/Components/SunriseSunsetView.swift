//
//  SunriseSunsetView.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

// Create a new file: SunriseSunsetView.swift

// In OpenMeteoWeatherApp/Views/Components/SunriseSunsetView.swift

import SwiftUI

struct SunriseSunsetView: View {
    let sunriseTime: String
    let sunsetTime: String

    var body: some View {
        HStack {
            Spacer()
            // Sunrise
            VStack {
                Image(systemName: "sunrise.fill")
                    .renderingMode(.original)
                Text("Sunrise")
                    .font(.caption)
                // NEW: Use the common helper. This will now display the time correctly.
                Text(DateHelper.formatTime(from: sunriseTime))
                    .fontWeight(.semibold)
            }
            Spacer()
            // Sunset
            VStack {
                Image(systemName: "sunset.fill")
                    .renderingMode(.original)
                Text("Sunset")
                    .font(.caption)
                // NEW: Use the common helper here as well.
                Text(DateHelper.formatTime(from: sunsetTime))
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
