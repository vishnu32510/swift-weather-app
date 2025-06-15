// In OpenMeteoWeatherApp/Views/Main/HourlyGraphView.swift

import SwiftUI
import Charts

struct HourlyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let weatherCode: Int
}

struct HourlyGraphView: View {
    @State private var selectedDate: Date?

    let hourlyData: Hourly

    private var dataPoints: [HourlyDataPoint] {
        var points: [HourlyDataPoint] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        let now = Date()
        let forecastLimit = 12
        var pointsAdded = 0

        for i in 0..<hourlyData.time.count where pointsAdded < forecastLimit {
            if let date = formatter.date(from: hourlyData.time[i]),
               let temp = hourlyData.temperature2M[i],
               let code = hourlyData.weatherCode[i],
               date >= now {
                points.append(HourlyDataPoint(date: date, temperature: temp, weatherCode: code))
                pointsAdded += 1
            }
        }
        return points
    }

    private var highTempDataPoint: HourlyDataPoint? {
        dataPoints.max(by: { $0.temperature < $1.temperature })
    }
    private var lowTempDataPoint: HourlyDataPoint? {
        dataPoints.min(by: { $0.temperature < $1.temperature })
    }
    
    private var selectedDataPoint: HourlyDataPoint? {
        guard let selectedDate else { return nil }
        return dataPoints.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })
    }
    
    var body: some View {
        ZStack {
            // NEW: Updated background to match the screenshot
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.4, green: 0.8, blue: 1.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // The dynamic header
                VStack {
                    if let selectedDataPoint {
                        Text("Time: \(selectedDataPoint.date, format: .dateTime.hour().minute())")
                        Text("Temp: \(Int(selectedDataPoint.temperature.rounded()))°")
                            .font(.title.bold())
                    } else {
                        Text("Next 12 Hours")
                        Text("Tap or drag on the chart to see details")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(height: 60)
                .padding(.top)

                VStack {
                    Chart {
                        ForEach(dataPoints) { point in
                            // The solid yellow area
                            AreaMark(
                                x: .value("Time", point.date),
                                y: .value("Temp", point.temperature)
                            )
                            .foregroundStyle(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.yellow.opacity(0.5), .blue.opacity(0.2)]),
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .interpolationMethod(.catmullRom)
                            
                        }
                        
                        // H/L Annotations
                        if let highTempDataPoint {
                             PointMark(x: .value("Time", highTempDataPoint.date), y: .value("Temp", highTempDataPoint.temperature))
                                .annotation(position: .top, alignment: .center) {
                                    VStack(spacing: 2) {
                                        Text("H: \(Int(highTempDataPoint.temperature.rounded()))°")
                                        Text(highTempDataPoint.date, format: .dateTime.hour().minute())
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(6)
                                }
                        }
                        
                        if let lowTempDataPoint {
                             PointMark(x: .value("Time", lowTempDataPoint.date), y: .value("Temp", lowTempDataPoint.temperature))
                                .annotation(position: .bottom, alignment: .trailing) {
                                    VStack(spacing: 2) {
                                        Text("L: \(Int(lowTempDataPoint.temperature.rounded()))°")
                                        Text(lowTempDataPoint.date, format: .dateTime.hour().minute())
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(6)
                                }
                        }
                    }
                    .chartYAxis(.hidden) // Hide the Y-axis labels as in the screenshot
                    .chartXAxis(.hidden) // Hide the X-axis labels as in the screenshot
                    .chartXSelection(value: $selectedDate)
                    // NEW: Add the chartOverlay to place the icons at the top.
                                        .chartOverlay { proxy in
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    ForEach(dataPoints) { point in
                                                        Image(systemName: WeatherCodeMapper.symbol(for: point.weatherCode))
                                                            .renderingMode(.original)
                                                            .font(.body)
                                                            .padding(6)
                                                            
                                                    }
                                                }
                                                Spacer() // Pushes the HStack to the top of the overlay
                                            }
                                            .padding(.top, 8)
                                        }
                }
                .frame(height: 300)
                .background(.white.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
        }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.clear, for: .navigationBar)
    }
}


#Preview {
    // We must create mock data for the preview to work.
    struct PreviewWrapper: View {
        // Create a function to generate sample data for the next 15 hours.
        private func createMockHourlyData() -> Hourly {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            var times: [String] = []
            var temps: [Double?] = []
            var codes: [Int?] = []
            
            let now = Date()
            let temperatures = [15.0, 16.0, 18.0, 20.0, 22.0, 23.0, 22.5, 21.0, 19.0, 18.0, 17.0, 16.0, 15.0, 14.0, 14.0]
            let weatherCodes = [1, 1, 0, 0, 0, 0, 1, 2, 3, 3, 2, 1, 1, 1, 2] // Clear, partly cloudy, etc.
            
            for i in 0..<15 {
                let date = now.addingTimeInterval(TimeInterval(i * 3600)) // Add 'i' hours
                times.append(formatter.string(from: date))
                temps.append(temperatures[i])
                codes.append(weatherCodes[i])
            }
            
            return Hourly(
                time: times,
                temperature2M: temps,
                relativeHumidity2M: [], // Not needed for this view
                apparentTemperature: [], // Not needed for this view
                precipitationProbability: [], // Not needed for this view
                weatherCode: codes,
                cloudCover: [], // Not needed for this view
                windSpeed10M: [] // Not needed for this view
            )
        }
        
        var body: some View {
            // Wrap in NavigationStack to see the title correctly.
            NavigationStack {
                HourlyGraphView(hourlyData: createMockHourlyData())
            }
        }
    }
    
    return PreviewWrapper()
}
