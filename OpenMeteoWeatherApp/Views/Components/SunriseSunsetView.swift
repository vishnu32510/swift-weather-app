//
//  SunriseSunsetView.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import SwiftUI

struct SunriseSunsetView: View {
    let sunriseTime: String
    let sunsetTime: String

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "sunrise.fill")
                    .renderingMode(.original)
                Text("Sunrise")
                    .font(.caption)

                Text(DateHelper.formatTime(from: sunriseTime))
                    .fontWeight(.semibold)
            }
            Spacer()
            VStack {
                Image(systemName: "sunset.fill")
                    .renderingMode(.original)
                Text("Sunset")
                    .font(.caption)

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
