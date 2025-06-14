//
//  DailyForeCasteListView.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/15/25.
//

import Foundation
import SwiftUI

struct DailyForeCasteListView: View {
    let daily: Daily
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("10-DAY FORECAST")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading)
            
            
            
            VStack {
                ForEach(daily.time.indices, id: \.self) { index in
                    rowView(for: index)
                }
            }
            .background(.white.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
        private func rowView(for index: Int) -> some View {
            DailyForecastRow(
                isToday: index == 0,
                dayOfWeek: dayOfWeek(from: daily.time[index]),
            
                imageName: WeatherCodeMapper.symbol(for: daily.weatherCode[index] ?? 1),
                precipitationProbability: daily.precipitationProbabilityMax[index] ?? 0,
                minTemp: Int((daily.temperature2MMin[index] ?? 0).rounded()),
                maxTemp: Int((daily.temperature2MMax[index] ?? 0).rounded())
            )
        }
    

    private func dayOfWeek(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else {
            return "N/A"
        }
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).uppercased()
    }
}
