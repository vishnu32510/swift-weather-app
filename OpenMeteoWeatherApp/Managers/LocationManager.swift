import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
    }
    
    func requestLocation() {
    
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
        
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
        
            error = NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access is denied. Please enable it in Settings."])
        case .authorizedWhenInUse, .authorizedAlways:
        
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func updatePlacemark(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = error
                    return
                }
                
                if let placemark = placemarks?.first {
                    self?.placemark = placemark
                }
            }
        }
    }
    

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
            
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.error = NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access is denied. Please enable it in Settings."])
            case .notDetermined:
            
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = locations.last {
                self.location = location
                self.updatePlacemark(for: location)
            
                manager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
} 