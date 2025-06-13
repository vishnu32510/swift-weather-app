import SwiftUI

struct WeatherButtonView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .frame(width: 280, height: 50)
            .background(Color.white)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(10)
    }
}

#Preview {
    WeatherButtonView(title: "Change Day Time")
        .background(Color.blue)
} 