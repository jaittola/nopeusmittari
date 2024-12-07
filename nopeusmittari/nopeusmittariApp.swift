import SwiftUI

@main
struct nopeusmittariApp: App {
    var gpsReceiver = GpsReceiverImpl()
    var gpsViewModel = GpsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gpsModel: gpsViewModel)
                .onAppear(perform: { gpsReceiver.start(gpsViewModel) })
                .onDisappear(perform: { gpsReceiver.stop() })
        }
    }
}
