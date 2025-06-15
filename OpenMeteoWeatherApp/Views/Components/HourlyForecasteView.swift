import SwiftUI

struct HourlyForecastView: View {
    
    let hourlyData: Hourly
    
    private var forecastIndices: Range<Int> {
        let startIndex = DateHelper.findCurrentHourIndex(in: hourlyData.time)
        let forecastRange = hourlyData.time.indices.suffix(from: startIndex).prefix(12)
        return forecastRange
    }
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack(spacing: 25) {
                
                
                ForEach(forecastIndices, id: \.self) { index in
                    hourlyItemView(for: index)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .foregroundColor(.white)
        .background(.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    @ViewBuilder
        private func hourlyItemView(for index: Int) -> some View {
            let startIndex = DateHelper.findCurrentHourIndex(in: hourlyData.time)
            
            VStack(spacing: 12) {
                
                
                Text(index == startIndex ? "Now" : DateHelper.formatHour(from: hourlyData.time[index]))
                    .fontWeight(.semibold)
                
                Image(systemName: WeatherCodeMapper.symbol(for: hourlyData.weatherCode[index] ?? 0))
                    .renderingMode(.original)
                    .font(.title2)
                    
                if let probability = hourlyData.precipitationProbability[index], probability > 10 {
                    Text("\(probability)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                Text("\(Int((hourlyData.temperature2M[index] ?? 0).rounded()))°")
                    .fontWeight(.semibold)
            }
        }


















//







//







//








}
