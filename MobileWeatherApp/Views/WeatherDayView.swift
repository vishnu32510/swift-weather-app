import SwiftUI

struct WeatherDayView: View {
    let dayOfWeek: String
    let imageName: String
    let temperature: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
            
            Text("\(temperature)°")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
        )
    }
}

#Preview {
    ZStack {
        Color.blue
        WeatherDayView(dayOfWeek: "MON", imageName: "cloud.sun.fill", temperature: 75)
    }
} 