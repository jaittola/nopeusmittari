import Foundation
import CoreLocation

@MainActor
protocol GpsModel: ObservableObject {
    var locationAvailable: Bool { get }
    var speed: Double { get }
    var course: Double { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var horizontalAccuracy: Double { get }
    var stationary: Bool { get }
    var hasAccurateLocation: Bool { get }
    
    func start()
    func stop()
}

class GpsModelImpl: GpsModel {
    @Published var locationAvailable: Bool = false
    @Published var speed: Double = 0
    @Published var course: Double = 0
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var horizontalAccuracy: Double = -1
    @Published var stationary: Bool = true
    @Published var hasAccurateLocation: Bool = false
    
    private var updater: Task<Void, Never>?
    
    func start() {
        NSLog("GpsModelImpl: start")
        
        if updater != nil {
            NSLog("GpsModelImpl: start: apparently updater is already running")
        }
            
        self.updater = Task {
            NSLog("Starting updater")
            let stream = CLLocationUpdate.liveUpdates(.otherNavigation)
            
            do {
                for try await update in stream {
                    guard !Task.isCancelled else {
                        NSLog("Task was cancelled, stopping")
                        self.updater = nil
                        self.locationAvailable = false
                        self.hasAccurateLocation = false
                        return
                    }
                    
                    guard !update.authorizationDenied else {
                        NSLog("No location permission")
                        self.locationAvailable = false
                        self.hasAccurateLocation = false
                        continue
                    }
                    
                    if let location = update.location {
                        self.locationAvailable = true
                        
                        self.hasAccurateLocation = !(update.accuracyLimited || location.horizontalAccuracy <= 0 || location.horizontalAccuracy > kCLLocationAccuracyHundredMeters)
                        
                        NSLog("Setting speed to \(location.speed)")
                        self.speed = location.speed
                        self.course = location.course
                        self.latitude = location.coordinate.latitude
                        self.longitude = location.coordinate.longitude
                        self.horizontalAccuracy = location.horizontalAccuracy
                        self.stationary = update.stationary
                    } else {
                        self.locationAvailable = false
                        self.hasAccurateLocation = false
                    }
                }
            } catch {
                NSLog("Getting location updates failed: \(error)")
                self.updater = nil
                return
            }
        }
    }
    
    func stop() {
        NSLog("GpsModelImpl: stop")
        
        self.updater?.cancel()
        self.updater = nil
    }
}

class FixedGpsModel: GpsModel {
    @Published var locationAvailable: Bool = true
    @Published var speed: Double = 30
    @Published var course: Double = 21.3
    @Published var latitude: Double = 60
    @Published var longitude: Double = 25
    @Published var horizontalAccuracy: Double = -1
    @Published var stationary: Bool = true
    @Published var hasAccurateLocation = true
 
    func start() {
        NSLog("FixedGpsModel: start")
    }
    
    func stop() {
        NSLog("FixedGpsModel: stop")
    }
}

class FixedNoLocationPermission: GpsModel {
    @Published var locationAvailable: Bool = false
    @Published var speed: Double = -1
    @Published var course: Double = -1
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var horizontalAccuracy: Double = -1
    @Published var stationary: Bool = true
    @Published var hasAccurateLocation = false
 
    func start() {
        NSLog("FixedNoLocationPermission: start")
    }
    
    func stop() {
        NSLog("FixedNoLocationPermission: stop")
    }
}

class FixedPoorLocationAccuracy: GpsModel {
    @Published var locationAvailable: Bool = true
    @Published var speed: Double = -1
    @Published var course: Double = -1
    @Published var latitude: Double = 60
    @Published var longitude: Double = 25
    @Published var horizontalAccuracy: Double = 900
    @Published var stationary: Bool = false
    @Published var hasAccurateLocation = false
 
    func start() {
        NSLog("FixedPoorLocationAccuracy: start")
    }
    
    func stop() {
        NSLog("FixedPoorLocationAccuracy: stop")
    }


}
