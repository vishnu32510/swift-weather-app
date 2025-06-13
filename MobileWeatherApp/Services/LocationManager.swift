//
//  LocationManager.swift
//  MobileWeatherApp
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 6/13/25.
//

import Foundation
import CoreLocation
import SwiftUI // For @Published

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManager is the central object for configuring and coordinating the delivery of location events.
    private let locationManager = CLLocationManager()
    private let locationCache = UserDefaults.standard

    // Published properties to notify SwiftUI views of changes.
    @Published var location: CLLocation? // Stores the current location.
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastKnownLocation: CLLocation?
    @Published var isUpdatingLocation = false
    @Published var error: LocationError?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var lastKnownCity: String?

    enum LocationError: LocalizedError {
        case locationServicesDisabled
        case locationDenied
        case locationRestricted
        case locationUpdateFailed(Error)
        case geocodingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .locationServicesDisabled:
                return "Location services are disabled. Please enable them in Settings."
            case .locationDenied:
                return "Location access was denied. Please enable it in Settings."
            case .locationRestricted:
                return "Location access is restricted."
            case .locationUpdateFailed(let error):
                return "Failed to update location: \(error.localizedDescription)"
            case .geocodingFailed(let error):
                return "Failed to get city name: \(error.localizedDescription)"
            }
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self // Set the delegate to self to receive location updates.
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.distanceFilter = 1000 // Update location when user moves 1km
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .other
        
        // Only enable background updates if we have the proper authorization
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .authorizedAlways:
                locationManager.allowsBackgroundLocationUpdates = true
            case .authorizedWhenInUse:
                locationManager.allowsBackgroundLocationUpdates = false
            default:
                locationManager.allowsBackgroundLocationUpdates = false
            }
        }
        
        // Load cached location if available
        if let cachedLatitude = locationCache.object(forKey: "cachedLatitude") as? Double,
           let cachedLongitude = locationCache.object(forKey: "cachedLongitude") as? Double {
            self.location = CLLocation(latitude: cachedLatitude, longitude: cachedLongitude)
        }
        
        self.authorizationStatus = locationManager.authorizationStatus
        self.lastKnownCity = locationCache.string(forKey: "lastKnownCity")
    }

    // Requests "When In Use" authorization from the user.
    func requestLocation() {
        isLoading = true
        locationManager.requestWhenInUseAuthorization()
        // Once authorization is granted, start updating location.
        locationManager.startUpdatingLocation()
    }

    // Requests background location authorization from the user.
    func requestBackgroundLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    // Starts updating location.
    func startUpdatingLocation() {
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }

    // Stops updating location.
    func stopUpdatingLocation() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    // Gets the current location.
    func getCurrentLocation() {
        locationManager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    // Called when the authorization status changes for the application.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        
        // Update background location settings based on new authorization status
        if CLLocationManager.locationServicesEnabled() {
            switch manager.authorizationStatus {
            case .authorizedAlways:
                locationManager.allowsBackgroundLocationUpdates = true
            case .authorizedWhenInUse:
                locationManager.allowsBackgroundLocationUpdates = false
            case .denied:
                error = .locationDenied
            case .restricted:
                error = .locationRestricted
            default:
                locationManager.allowsBackgroundLocationUpdates = false
            }
        } else {
            error = .locationServicesDisabled
        }
        
        authorizationStatus = manager.authorizationStatus // Update the published status.
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied:
            error = .locationDenied
            isLoading = false
        case .restricted:
            error = .locationRestricted
            isLoading = false
        default:
            break
        }
    }

    // Called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the most recent location from the array.
        guard let latestLocation = locations.last else { return }
        
        // Cache the new location
        locationCache.set(latestLocation.coordinate.latitude, forKey: "cachedLatitude")
        locationCache.set(latestLocation.coordinate.longitude, forKey: "cachedLongitude")
        
        location = latestLocation // Update the published location.
        isLoading = false
        self.lastKnownLocation = latestLocation
        
        // Reverse geocode for city name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(latestLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.error = .geocodingFailed(error)
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown City"
                self.lastKnownCity = city
                self.locationCache.set(city, forKey: "lastKnownCity")
            }
        }
        
        // Stop updates if we're not in background mode
        if !manager.allowsBackgroundLocationUpdates {
            manager.stopUpdatingLocation()
        }
    }

    // Called when the location manager encounters an error.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = .locationUpdateFailed(error)
        isLoading = false
        print("Location manager failed with error: \(error.localizedDescription)")
        // Handle error appropriately, e.g., display an alert to the user.
    }
}

// Extension to CLLocation to make it identifiable and provide a locality property for UI display.
extension CLLocation: Identifiable {
    public var id: UUID { UUID() } // Conforming to Identifiable
    // This is a placeholder for demonstration. In a real app, you'd typically store
    // the placemark's locality in your own `Location` model or within the `LocationManager`.
    // Stored properties cannot be added directly via extensions.
    var locality: String? {
        get {
            // This property is read-only for demonstration.
            // In a real app, you'd manage this via `LocationManager` and `@Published` properties.
            return nil // Return nil as we can't directly store it here.
        }
    }
}
