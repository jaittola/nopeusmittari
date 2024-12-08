import SwiftUI

@main
struct nopeusmittariApp: App {
    var gpsViewModel = GpsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gpsModel: gpsViewModel)
                .onAppear(perform: { GpsReceiverImpl.shared.start(gpsViewModel) })
                .onDisappear(perform: { GpsReceiverImpl.shared.stop() })
        }
    }
}
