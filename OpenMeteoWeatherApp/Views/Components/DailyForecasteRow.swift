//
//  DailyForecasteRow.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/14/25.
//

import Foundation
import SwiftUI

struct DailyForecastRow: View {
    var isToday: Bool
    var dayOfWeek: String
    var imageName: String
    var precipitationProbability: Int
    var minTemp: Int
    var maxTemp: Int

    var body: some View {
        HStack(spacing: 16) {
            Text(isToday ? "Today" : dayOfWeek)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)

            VStack(spacing: 0) {
                Image(systemName: imageName)
                    .renderingMode(.original)
                    .font(.title2)
                    .padding(.bottom, 2)
                
                if precipitationProbability > 25 {
                    Text("\(precipitationProbability)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
            }
            .frame(width: 50)

            // Min temperature
            Text("\(minTemp)°")
                .fontWeight(.medium)
            
            // Temperature range bar
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .green, .yellow, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 5)

            // Max temperature
            Text("\(maxTemp)°")
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}
