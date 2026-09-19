import Foundation
import SwiftData
import UIKit

/// Local-only storage. CloudKit is explicitly disabled: nothing leaves this iPhone.
enum StorageManager {
    static let settingsKeys = ["mapMode", "mapStyle", "show3D", "appearance"]

    static func makeContainer() -> ModelContainer {
        let schema = Schema([SavedPlace.self])
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not open the local database: \(error)")
        }
    }

    /// Keeps photos small so the database stays fast.
    static func downsized(_ data: Data, maxDimension: CGFloat = 1400, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        let scale = min(1, maxDimension / longest)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).jpegData(withCompressionQuality: quality) { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    @MainActor
    static func deleteAll(context: ModelContext) {
        try? context.delete(model: SavedPlace.self)
        try? context.save()
        settingsKeys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        URLCache.shared.removeAllCachedResponses()
    }
}
