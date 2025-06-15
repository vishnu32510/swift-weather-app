# OpenMeteo Weather Assistant

A modern, feature-rich weather assistant built natively for iOS using SwiftUI. This application goes beyond simple data display by integrating AI to provide users with personalized and context-aware activity suggestions.

## Core Features

### Frontend
- A sleek, single-page interface built with SwiftUI
- Dynamic backgrounds that adapt to the time of day (day/night)
- Intuitive navigation and responsive layout
- Accessibility support

### Backend Integration
The app reliably fetches and parses data from two key backend services:
- **Open-Meteo API**: For real-time weather conditions, detailed hourly forecasts, and 16-day daily forecasts
- **Google Gemini API**: For generating creative and helpful weather-based suggestions

### Location-Aware
- Automatically detects the user's location
- Provides accurate, localized weather data
- Efficient location updates with privacy considerations

## Advanced & Differentiating Features

### AI-Powered Insights
The app's standout feature synthesizes current and daily weather data into a detailed summary, which is then sent to the Gemini LLM to generate unique, actionable suggestions for the user (e.g., "🚴 Energetic day for biking through the lakeside trail").

### Intelligent Notifications & Background Processing
The app implements a robust notification system and leverages background tasks (BGTaskScheduler) to:
- Schedule a daily 7 AM forecast notification
- Periodically fetch weather and AI suggestions in the background
- Send users a "Daily Weather Tip" as a push notification—a truly unique update not found in standard weather apps

### Robust Architecture
- Built on a clean MVVM architecture
- Clear separation of concerns (Views, Services, Managers)
- Modern Swift practices including async/await for concurrency
- Well-structured notification and location management system

## Device-Specific Features

### Real Device Features
The following features are only available on physical iOS devices:
- **AI LLM Service**: The AI-powered weather suggestions and insights
- **Background Tasks**: Weather updates and notifications in the background
- **Push Notifications**: Real-time weather alerts and daily forecasts

### Simulator Limitations
When running the app in the iOS Simulator:
- AI LLM Service will not function
- Background tasks will not execute
- Push notifications will not be delivered
- Some location-based features may be limited

## Technical Implementation

### Architecture
- **MVVM Architecture**: Clean separation of concerns
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Async/Await**: Modern concurrency handling

### Key Components
1. **Weather Service**
   - RESTful API integration with Open-Meteo
   - Intelligent caching system
   - Rate limiting and retry mechanisms
   - Comprehensive error handling

2. **Location Services**
   - Real-time location updates
   - Geocoding support
   - Privacy-aware implementation

3. **Notification System**
   - Custom weather alerts
   - Daily forecast notifications
   - Intelligent weather event detection

4. **AI Integration**
   - Weather data analysis
   - Personalized suggestions
   - Natural language processing

## Screenshots

[Add your app screenshots here]

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Physical iOS device for full feature support

### Installation
1. Clone the repository
```bash
git clone https://github.com/vishnu32510/OpenMeteoWeatherApp.git
```

2. Open the project in Xcode
```bash
cd OpenMeteoWeatherApp
open OpenMeteoWeatherApp.xcodeproj
```

3. Build and run the project:
   - For full feature testing: Use a physical iOS device
   - For basic functionality testing: Use the iOS simulator

## Project Structure

```
OpenMeteoWeatherApp/
├── Views/
│   ├── Main/
│   │   └── ContentView.swift
│   └── Components/
├── Services/
│   └── WeatherService.swift
├── Models/
├── Managers/
└── Utilities/
```

## API Integration

The app uses the Open-Meteo API to fetch weather data, including:
- Current weather conditions
- Hourly forecasts
- Daily forecasts
- Temperature, precipitation, wind, and more

## Data Models

- Current weather conditions
- Hourly forecast data
- Daily forecast data
- Location information
- Weather alerts

## Privacy & Permissions

The app requires the following permissions:
- Location Services
- Push Notifications
- Background App Refresh

## UI/UX Features

- Dynamic backgrounds based on time of day
- Smooth animations and transitions
- Intuitive navigation
- Responsive layout
- Accessibility support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Vishnu Priyan Sellam Shanmugavel

## Contact & Links

- LinkedIn: [Vishnu Priyan](https://www.linkedin.com/in/vishnu32510/)
- GitHub: [vishnu32510](https://github.com/vishnu32510)
- Devpost: [vishnu32510](https://devpost.com/vishnu32510)
- Personal Website: [vishnupriyan-ss.web.app](https://vishnupriyan-ss.web.app/)

## Acknowledgments

- Open-Meteo API for weather data
- Google Gemini API for AI integration
- Apple's SwiftUI framework
- The iOS development community 