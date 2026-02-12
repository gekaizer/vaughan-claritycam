import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var placemark: CLPlacemark?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        reverseGeocode(newLocation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.placemark = placemark
                }
            }
        }
    }

    // MARK: - Formatting Helpers

    var coordinateString: String {
        guard let location = location else { return "—" }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        return "\(formatDMS(lat, isLatitude: true)), \(formatDMS(lon, isLatitude: false))"
    }

    var latitudeString: String {
        guard let location = location else { return "—" }
        return formatDMS(location.coordinate.latitude, isLatitude: true)
    }

    var longitudeString: String {
        guard let location = location else { return "—" }
        return formatDMS(location.coordinate.longitude, isLatitude: false)
    }

    var headingString: String {
        guard let heading = heading, heading.trueHeading >= 0 else { return "—" }
        let degrees = Int(heading.trueHeading)
        let direction = cardinalDirection(from: heading.trueHeading)
        return "\(degrees)\u{00B0} \(direction)"
    }

    var addressString: String {
        guard let placemark = placemark else { return "—" }
        let street = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        return street.isEmpty ? "—" : street
    }

    var cityProvincePostalString: String {
        guard let placemark = placemark else { return "—" }
        let parts = [
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode
        ].compactMap { $0 }
        return parts.joined(separator: " ")
    }

    var countryString: String {
        return placemark?.country ?? "—"
    }

    private func formatDMS(_ decimal: Double, isLatitude: Bool) -> String {
        let direction = isLatitude
            ? (decimal >= 0 ? "N" : "S")
            : (decimal >= 0 ? "E" : "W")
        let absolute = abs(decimal)
        let degrees = Int(absolute)
        let minutesDecimal = (absolute - Double(degrees)) * 60
        let minutes = Int(minutesDecimal)
        let seconds = Int((minutesDecimal - Double(minutes)) * 60)
        return "\(direction) \(degrees)\u{00B0} \(minutes)' \(seconds)\""
    }

    private func cardinalDirection(from degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }
}
