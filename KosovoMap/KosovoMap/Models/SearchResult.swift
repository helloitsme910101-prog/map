import SwiftUI
import CoreLocation

struct DroppedPin: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String?
}

struct SearchResult: Identifiable {
    enum Kind {
        case saved, city, place

        var tint: Color {
            switch self {
            case .saved: Theme.gold
            case .city: Theme.cobalt
            case .place: Color(red: 0.36, green: 0.40, blue: 0.52)
            }
        }
    }

    let id: String
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let kind: Kind
    let symbol: String

    var coordinateText: String {
        String(format: "%.2f°, %.2f°", coordinate.latitude, coordinate.longitude)
    }
}
