# OpenMeteo Weather App

A modern, feature-rich weather application built with SwiftUI that provides real-time weather information and intelligent weather insights using the Open-Meteo API.

## Features

### Core Features
- **Real-time Weather Data**: Get current weather conditions for your location
- **Hourly Forecast**: View detailed hourly weather predictions
- **Daily Forecast**: Plan ahead with 16-day weather forecasts
- **Location-based**: Automatically detects and updates weather for your current location
- **Modern UI**: Clean, intuitive interface with dynamic backgrounds based on time of day

### Advanced Features
- **AI-Powered Weather Insights**: Get personalized weather suggestions and insights
- **Smart Notifications**: Receive intelligent weather alerts for significant changes
- **Dynamic UI**: Beautiful animations and transitions
- **Offline Support**: Cached weather data for offline access
- **Error Handling**: Robust error handling with retry mechanisms

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
git clone https://github.com/yourusername/OpenMeteoWeatherApp.git
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

## Acknowledgments

- Open-Meteo API for weather data
- Apple's SwiftUI framework
- The iOS development community 