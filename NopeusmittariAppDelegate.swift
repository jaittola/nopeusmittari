import Foundation
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let gpsReceiver = GpsReceiverImpl.shared
        let gpsViewModel = GpsViewModel.shared
        
        // If location updates were previously active, restart them after the background launch.
        if gpsReceiver.updatesStarted {
            gpsReceiver.start(gpsViewModel)
        }
        // If a background activity session was previously active, reinstantiate it after the background launch.
        if gpsReceiver.backgroundActivity {
            gpsReceiver.backgroundActivity = true
        }
        return true
    }
}
