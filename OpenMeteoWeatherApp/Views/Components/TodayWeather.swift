//
//  TodayWeather.swift
//  OpenMeteoWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/14/25.
//

import Foundation
import SwiftUI

struct TodayWeather: View {
    // New properties to hold all the required data
    let weatherCode: Int
    let locality: String
    var imageName: String
    let currentTemp: Int
    
    var body: some View {
        VStack(spacing: 4) {
            CityView(cityName: locality)
            // Main Temperature Display
            Text("\(currentTemp)°")
                .font(.system(size: 80, weight: .thin, design: .default))
            // Weather Description Text
            HStack{
                VStack(spacing: 0) {
                    Image(systemName: imageName)
                        .renderingMode(.original)
                        .font(.title2)
                        .padding(.bottom, 2)
                }
                .frame(width: 20)
                Text(WeatherCodeMapper.description(for: weatherCode))
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(.white)
        .padding(.bottom, 20)
    }
}
