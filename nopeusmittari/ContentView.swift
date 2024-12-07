
import SwiftUI

struct ContentView: View {

    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
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
        }
        .padding()
        Spacer()
    }
}

#Preview {
    
    
    ContentView(gpsModel: testViewModel(FixedPoorLocationAccuracy()))
}
