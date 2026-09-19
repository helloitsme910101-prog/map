import Foundation
import CoreLocation

/// Thin client for Photon (OpenStreetMap search by komoot), limited to Kosovo's bounding box.
/// Only the text you type is sent. Saved places and history never are.
struct PhotonClient {
    struct Response: Decodable {
        let features: [Feature]
    }
    struct Feature: Decodable {
        let geometry: Geometry
        let properties: Properties
    }
    struct Geometry: Decodable {
        let coordinates: [Double]   // [lon, lat]
    }
    struct Properties: Decodable {
        let osm_id: Int?
        let osm_key: String?
        let osm_value: String?
        let name: String?
        let street: String?
        let housenumber: String?
        let district: String?
        let city: String?
        let county: String?
        let state: String?
    }

    private let session = URLSession(configuration: .ephemeral)   // no cookies, no disk cache

    func search(_ query: String, limit: Int = 8) async throws -> [SearchResult] {
        var comps = URLComponents(string: "https://photon.komoot.io/api/")!
        comps.queryItems = [
            .init(name: "q", value: query),
            .init(name: "limit", value: String(limit)),
            .init(name: "bbox", value: KosovoGeo.bbox),
        ]
        let response = try await fetch(comps.url!)
        return response.features.compactMap(Self.result(from:))
    }

    func reverse(_ coordinate: CLLocationCoordinate2D) async -> String? {
        var comps = URLComponents(string: "https://photon.komoot.io/reverse")!
        comps.queryItems = [
            .init(name: "lon", value: String(coordinate.longitude)),
            .init(name: "lat", value: String(coordinate.latitude)),
            .init(name: "limit", value: "1"),
        ]
        guard let response = try? await fetch(comps.url!),
              let props = response.features.first?.properties else { return nil }
        let title = Self.title(for: props)
        return title.isEmpty ? nil : title
    }

    // MARK: Private

    private func fetch(_ url: URL) async throws -> Response {
        var request = URLRequest(url: url, timeoutInterval: 8)
        request.setValue("KosovoMap/1.0 (personal iOS app)", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private static func title(for p: Properties) -> String {
        if let name = p.name, !name.isEmpty { return name }
        return [p.street, p.housenumber].compactMap { $0 }.joined(separator: " ")
    }

    private static func result(from f: Feature) -> SearchResult? {
        guard f.geometry.coordinates.count >= 2 else { return nil }
        let p = f.properties
        let title = title(for: p)
        guard !title.isEmpty else { return nil }

        var parts: [String] = []
        if p.name != nil, let street = p.street { parts.append([street, p.housenumber].compactMap { $0 }.joined(separator: " ")) }
        if let place = p.city ?? p.district { parts.append(place) }
        if let region = p.county ?? p.state, !parts.contains(region) { parts.append(region) }
        parts.append("Kosovo")

        let coordinate = CLLocationCoordinate2D(latitude: f.geometry.coordinates[1], longitude: f.geometry.coordinates[0])
        return SearchResult(
            id: "photon-\(p.osm_id ?? Int.random(in: 0...Int.max))-\(title)",
            title: title,
            subtitle: parts.joined(separator: ", "),
            coordinate: coordinate,
            kind: .place,
            symbol: symbol(key: p.osm_key, value: p.osm_value)
        )
    }

    private static func symbol(key: String?, value: String?) -> String {
        if key == "place" { return "building.2.fill" }
        if key == "highway" { return "road.lanes" }
        if key == "shop" { return "bag.fill" }
        if key == "amenity", ["restaurant", "cafe", "fast_food", "bar", "pub"].contains(value ?? "") { return "fork.knife" }
        if key == "leisure", value == "fitness_centre" { return "dumbbell.fill" }
        return "mappin.circle.fill"
    }
}
