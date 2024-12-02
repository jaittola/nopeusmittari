import SwiftUI
import CoreLocation

struct SpeedView<GpsViewModel>: View where GpsViewModel: GpsModel {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        let sp = switch gpsModel.stationary {
        case true:
            "0"
        case _ where gpsModel.hasAccurateLocation && gpsModel.speed >= 0:
            String(format: "%.0f", 3.6 * gpsModel.speed)
        default:
            " ? "
        }
        
        HStack {
            Text(sp)
                .font(.system(size: 120, weight: .bold))
                .padding(.trailing, 10)
            Text("km/h")
                .font(.system(size: 24, weight: .bold))
        }
    }
}

struct CourseView<GpsViewModel>: View where GpsViewModel: GpsModel {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        let course = gpsModel.course >= 0 ? String(format: "%.0f°", gpsModel.course) : "-"
        
        Text(String(format: "Course: %@", course))
    }
}

struct CoordinatesView<GpsViewModel>: View where GpsViewModel: GpsModel {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        VStack {
            Text(String(format: "Latitude: %.3f°", gpsModel.latitude))
            Text(String(format: "Longitude: %.3f°", gpsModel.longitude))
        }
    }
}

struct AccuracyView<GpsViewModel>: View where GpsViewModel: GpsModel {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        switch gpsModel.horizontalAccuracy {
        case _ where gpsModel.horizontalAccuracy <= 0:
            Text("Low position accuracy")
        case _ where !gpsModel.hasAccurateLocation || gpsModel.horizontalAccuracy > kCLLocationAccuracyKilometer:
            Text(String(format: "Accuracy %.0f m (very low)", gpsModel.horizontalAccuracy))
         default:
            Text(String(format: "Accuracy %.0f m", gpsModel.horizontalAccuracy))
        }
    }
}

#Preview {
    VStack {
        SpeedView(gpsModel: FixedGpsModel())
    }
}
