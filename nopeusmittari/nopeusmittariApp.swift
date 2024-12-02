import SwiftUI

@main
struct nopeusmittariApp: App {
    var gpsModel = GpsModelImpl()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gpsModel: gpsModel)
                .onAppear(perform: { gpsModel.start() })
                .onDisappear(perform: { gpsModel.stop() })
        }
    }
}
