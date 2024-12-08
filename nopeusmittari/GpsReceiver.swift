import Foundation
import CoreLocation

@MainActor
protocol GpsReceiver: ObservableObject {
    func start(_ viewModel: GpsViewModel)
    func stop()
}

class GpsReceiverImpl: GpsReceiver {
    static let shared = GpsReceiverImpl()  // Create a single, shared instance of the object.
    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?
    
    private var updater: Task<Void, Never>?
        
    private init() {
        manager = CLLocationManager()
    }
    
    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted")
            NSLog("updates started \(updatesStarted)")
        }
    }
    
    @Published
    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
        didSet {
            NSLog("Background activity \(backgroundActivity)")
            backgroundActivity ?
            self.background = CLBackgroundActivitySession() :
            self.background?.invalidate()
            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }
    
    func start(_ viewModel: GpsViewModel) {
        NSLog("GpsModelImpl: start")
        
        if updater != nil {
            NSLog("GpsModelImpl: start: apparently updater is already running")
            return
        }
        
        self.updater = Task {
            NSLog("Starting updater")
            let stream = CLLocationUpdate.liveUpdates(.otherNavigation)
            updatesStarted = true
            
            do {
                for try await update in stream {
                    guard !Task.isCancelled else {
                        NSLog("Task was cancelled, stopping")
                        self.updater = nil
                        self.updatesStarted = false
                        viewModel.updateWithNoLocation()
                        return
                    }
                    
                    guard !update.authorizationDenied else {
                        NSLog("No location permission")
                        viewModel.updateWithNoLocation()
                        continue
                    }
                    
                    if let location = update.location {
                        NSLog("Location updated, \(update.location)")
                        viewModel.update(with: location,
                                         isAccuracyLimited: update.accuracyLimited,
                                         isStationary: update.stationary)
                    } else {
                        viewModel.updateWithNoLocation()
                    }
                }
            } catch {
                NSLog("Getting location updates failed: \(error)")
                self.updatesStarted = false
                self.updater = nil
                return
            }
        }
    }
    
    func stop() {
        NSLog("GpsModelImpl: stop")
        
        self.updater?.cancel()
        self.updater = nil
        self.updatesStarted = false
    }
}

class FixedGpsModel: GpsReceiver {
    func start(_ viewModel: GpsViewModel) {
        NSLog("FixedGpsModel: start")
        
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 60,
                                                                     longitude: 25),
                                  altitude: 200,
                                  horizontalAccuracy: 20,
                                  verticalAccuracy: 20,
                                  course: 21.3,
                                  speed: 30,
                                  timestamp: Date())
        
        viewModel.update(with: location,
                         isAccuracyLimited: false,
                         isStationary: false)
    }
    
    func stop() {
        NSLog("FixedGpsModel: stop")
    }
}

class FixedNoLocationPermission: GpsReceiver {
    func start(_ viewModel: GpsViewModel) {
        NSLog("FixedNoLocationPermission: start")
        viewModel.updateWithNoLocation()
    }
    
    func stop() {
        NSLog("FixedNoLocationPermission: stop")
    }
}

class FixedPoorLocationAccuracy: GpsReceiver {
    func start(_ viewModel: GpsViewModel) {
        NSLog("FixedPoorLocationAccuracy: start")
        
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 60,
                                                                     longitude: 25),
                                  altitude: 200,
                                  horizontalAccuracy: 900,
                                  verticalAccuracy: 900,
                                  course: -1,
                                  speed: -1,
                                  timestamp: Date())
        
        viewModel.update(with: location,
                         isAccuracyLimited: true,
                         isStationary: false)
        
    }
    
    func stop() {
        NSLog("FixedPoorLocationAccuracy: stop")
    }
}

@MainActor
func testViewModel(_ receiver: any GpsReceiver) -> GpsViewModel {
    let vm = GpsViewModel()
    receiver.start(vm)
    return vm
}
