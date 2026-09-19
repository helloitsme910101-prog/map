import Foundation
import SwiftData
import CoreLocation

@Model
final class SavedPlace {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var notes: String
    var latitude: Double
    var longitude: Double
    var date: Date
    @Attribute(.externalStorage) var photoData: Data?

    init(name: String,
         category: PlaceCategory,
         notes: String = "",
         coordinate: CLLocationCoordinate2D,
         date: Date = .now,
         photoData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.notes = notes
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.date = date
        self.photoData = photoData
    }

    var category: PlaceCategory {
        get { PlaceCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
