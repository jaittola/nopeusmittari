import Foundation
import CoreLocation

struct SpeedUnit {
    var label: String
    var conversion: Double
}

let speedUnits: [String: SpeedUnit] = [
    "kmh": SpeedUnit(label: "km/h", conversion: 3.6)
]

fileprivate extension FloatingPoint {
    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
}

class GpsViewModel: ObservableObject {
    static let shared = GpsViewModel()
    
    @Published var locationAvailable: Bool = false
    @Published var speedValue: Double = 0
    @Published var speedUnit: SpeedUnit = speedUnits["kmh"]!
    @Published var speed: String = " - "
    @Published var course: Double = 0
    @Published var latitudeValue: Double = 0
    @Published var longitudeValue: Double = 0
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var horizontalAccuracy: Double = -1
    @Published var stationary: Bool = true
    @Published var hasAccurateLocation: Bool = false
    
    func update(with location: CLLocation,
                isAccuracyLimited: Bool,
                isStationary: Bool) {
        self.locationAvailable = true
        
        self.hasAccurateLocation = !(isAccuracyLimited || location.horizontalAccuracy <= 0 || location.horizontalAccuracy > kCLLocationAccuracyHundredMeters)
        
        updateSpeed(newSpeed: location.speed,
                    hasAccurateLocation: hasAccurateLocation,
                    isStationary: isStationary)
        updateLocation(isLocationAvailable: true, location: location.coordinate)
        
        self.course = location.course
        self.horizontalAccuracy = location.horizontalAccuracy
        self.stationary = isStationary
    }
    
    func updateWithNoLocation() {
        self.locationAvailable = false
        self.hasAccurateLocation = false
        
        updateSpeed(newSpeed: 0, hasAccurateLocation: false, isStationary: false)
    }
    
    @MainActor
    func toggleLocationUpdating() {
        let gpsReceiver = GpsReceiverImpl.shared
        
        if gpsReceiver.updatesStarted {
            gpsReceiver.stop()
        } else {
            gpsReceiver.start(self)
        }
    }
    
    private func updateSpeed(newSpeed: Double,
                             hasAccurateLocation: Bool,
                             isStationary: Bool) {
        (speedValue, speed) = switch isStationary {
        case true:
            (0, "0")
        case _ where hasAccurateLocation && newSpeed >= 0:
            (newSpeed, String(format: "%.0f", speedUnit.conversion * newSpeed))
        default:
            (0, " - ")
        }
    }
    
    private func updateLocation(isLocationAvailable: Bool,
                                location: CLLocationCoordinate2D?) {
        if isLocationAvailable, let location = location {
            latitudeValue = location.latitude
            longitudeValue = location.longitude
            
            latitude = formatCoordinate("S", "N", latitudeValue)
            longitude = formatCoordinate("W", "E", longitudeValue)
        } else {
            latitudeValue = 0
            longitudeValue = 0
            
            latitude = ""
            longitude = ""
        }
    }
    
    private func formatCoordinate(_ negHemisphere: String,
                                  _ posHemisphere: String,
                                  _ coordinate: Double) -> String {
        let absCoordinate = fabs(coordinate)
        let minutes = absCoordinate.fraction * 60
        
        let hemisphere = switch coordinate {
        case _ where coordinate == 0:
            " "
        case _ where coordinate > 0:
            posHemisphere
        default:
            negHemisphere
        }
        
        return String(format: "%@ %.0f° %.03f'",
                      hemisphere,
                      absCoordinate.whole,
                      minutes)
    }
}
