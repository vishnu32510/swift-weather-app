import SwiftUI

struct BackgroundView: View {
    var isNight: Bool
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: isNight ? [Color.black, Color.gray] : [Color.blue, Color("lightBlue")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(isNight: false)
} 
