import SwiftUI

struct CityView: View {
    var cityName: String
    
    var body: some View {
        Text(cityName)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    CityView(cityName: "Cupertino, CA")
        .background(Color.blue)
} 