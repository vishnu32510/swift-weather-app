import SwiftUI

struct HourlyForecastView: View {
    // This view still receives the hourly data it needs
    let hourlyData: Hourly
    
    // MARK: - 1. Computed Property for Data
    // This private property prepares the list of indices we need to show.
    // The view's body is no longer responsible for this calculation.
    private var forecastIndices: Range<Int> {
        let startIndex = DateHelper.findCurrentHourIndex(in: hourlyData.time)
        let forecastRange = hourlyData.time.indices.suffix(from: startIndex).prefix(12)
        return forecastRange
    }
    
    // MARK: - 2. Main View Body
    // The body is now much simpler and easier for the compiler to read.
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack(spacing: 25) {
                // The ForEach loop now uses the simple computed property
                // and calls a helper function to create the view for each item.
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
    
    // MARK: - 3. Helper View Builder
    // This private function builds the view for a SINGLE hourly item.
    // The ForEach loop calls this repeatedly.
    @ViewBuilder
        private func hourlyItemView(for index: Int) -> some View {
            let startIndex = DateHelper.findCurrentHourIndex(in: hourlyData.time)
            
            VStack(spacing: 12) {
                // Time Label
                // NEW: Use the common helper
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
//    private func date(from string: String) -> Date? {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter.date(from: string)
//    }
//    
//    // MARK: - Helper Functions
//       
//       // --- THIS IS THE MISSING CODE ---
//       // These static properties create the formatters once and reuse them,
//       // which is much more efficient.
//       private static let parsingFormatter: DateFormatter = {
//           let formatter = DateFormatter()
//           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
//           formatter.locale = Locale(identifier: "en_US_POSIX")
//           formatter.timeZone = TimeZone(secondsFromGMT: 0)
//           return formatter
//       }()
//
//       private static let displayFormatter: DateFormatter = {
//           let formatter = DateFormatter()
//           formatter.dateFormat = "ha"
//           formatter.timeZone = .current
//           return formatter
//       }()
//       // --- END OF MISSING CODE ---
//
//       private func findCurrentHourIndex() -> Int {
//           let now = Date()
//           // Use the efficient parsing formatter
//           return hourlyData.time.firstIndex { timeString in
//               Self.parsingFormatter.date(from: timeString)?.timeIntervalSince(now) ?? -1 >= 0
//           } ?? 0
//       }
//
//       private func formatTime(from string: String) -> String {
//           // Use the efficient parsing formatter
//           guard let date = Self.parsingFormatter.date(from: string) else {
//               return "N/A"
//           }
//           // Use the efficient display formatter
//           return Self.displayFormatter.string(from: date).uppercased()
//       }
}
