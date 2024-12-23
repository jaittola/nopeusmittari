
import SwiftUI

struct ContentView: View {

    @ObservedObject
    var gpsModel: GpsViewModel
        
    var body: some View {
        let toggleButtonText = gpsModel.isReceivingLocation ? "Stop updating" : "Start updating"

        VStack {
            if !gpsModel.locationAvailable {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 50))
                    .padding(.top,  50)
                    .padding(.bottom, 40)
                Text("Location information is not available. Make sure that you have permitted this app to use location data.")
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 20)
            } else {
                AccuracyView(gpsModel: gpsModel)
                SpeedView(gpsModel: gpsModel)
                CourseView(gpsModel: gpsModel)
                    .padding(.bottom, 30)
                CoordinatesView(gpsModel: gpsModel)
            }
            Button(toggleButtonText) {
                gpsModel.toggleLocationUpdating()
            }
            .padding(.vertical, 20)
            .buttonStyle(.bordered)
        }
        .padding()
        Spacer()
    }
}

#Preview {
    ContentView(gpsModel: testViewModel(FixedPoorLocationAccuracy()))
}
