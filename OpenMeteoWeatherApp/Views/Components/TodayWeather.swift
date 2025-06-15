//
//  TodayWeather.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/14/25.
//

import Foundation
import SwiftUI

struct TodayWeather: View {
    let current: Current
    
    let locality: String
    
    var body: some View {
        VStack(spacing: 4) {
            CityView(cityName: locality)
            
            
            Text("\(Int(current.temperature2M.rounded()))°")
                .font(.system(size: 60, weight: .thin, design: .default))
            
            HStack {
                VStack(spacing: 0) {
                    
                    Image(systemName: WeatherCodeMapper.symbol(for: current.weatherCode))
                        .renderingMode(.original)
                        .font(.title2)
                        .padding(.bottom, 2)
                }
                .frame(width: 20)
                Text(WeatherCodeMapper.description(for: current.weatherCode))
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            
            Text("Feels like \(Int(current.apparentTemperature.rounded()))°")
                .font(.caption) 
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.15), in: Capsule())
                .padding(.top, 8)
            
            
            HStack(spacing: 20) {
                VStack {
                    Text("Humidity")
                        .font(.caption)
                    Text("\(current.relativeHumidity2M)%")
                        .fontWeight(.semibold)
                }
                VStack {
                    Text("Wind")
                        .font(.caption)
                    Text("\(Int(current.windSpeed10M.rounded())) km/h")
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 10)
        }
        .foregroundColor(.white)
        .padding(.bottom, 20)
    }
}
