import SwiftUI
import CoreLocation

struct SpeedView: View {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        HStack {
            Text(gpsModel.speed)
                .font(.system(size: 120, weight: .bold))
                .padding(.trailing, 10)
            Text(gpsModel.speedUnit.label)
                .font(.system(size: 24, weight: .bold))
        }
    }
}

struct CourseView: View {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        let course = gpsModel.course >= 0 ? String(format: "%.0f°", gpsModel.course) : "-"
        
        Text(String(format: "Course: %@", course))
    }
}

struct CoordinatesView: View {
    @ObservedObject
    var gpsModel: GpsViewModel
    
    var body: some View {
        VStack {
            Text(String(format: "Latitude: %@", gpsModel.latitude))
            Text(String(format: "Longitude: %@", gpsModel.longitude))
        }
    }
}

struct AccuracyView: View {
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
        SpeedView(gpsModel: testViewModel(FixedGpsModel()))
    }
}
