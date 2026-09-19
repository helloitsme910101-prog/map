import Foundation
import CoreLocation
import Observation

/// Search order: saved places → built-in Kosovo towns → online OpenStreetMap results.
/// Saved places and towns always work offline.
@MainActor
@Observable
final class SearchManager {
    private(set) var results: [SearchResult] = []
    private(set) var isLoading = false

    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private let photon = PhotonClient()

    func search(_ raw: String, saved: [SavedPlace], allowNetwork: Bool) {
        task?.cancel()
        let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            results = []
            isLoading = false
            return
        }

        let local = localMatches(query, saved: saved)
        results = local

        guard allowNetwork, query.count >= 2 else {
            isLoading = false
            return
        }

        isLoading = true
        task = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))      // debounce: be kind to the public service
            guard !Task.isCancelled, let self else { return }
            do {
                let remote = try await self.photon.search(query)
                guard !Task.isCancelled else { return }
                let known = Set(local.map { Self.normalize($0.title) })
                self.results = local + remote.filter { !known.contains(Self.normalize($0.title)) }
            } catch {
                // Offline or service unavailable: keep the local results.
            }
            if !Task.isCancelled { self.isLoading = false }
        }
    }

    func clear() {
        task?.cancel()
        results = []
        isLoading = false
    }

    func reverse(_ coordinate: CLLocationCoordinate2D) async -> String? {
        await photon.reverse(coordinate)
    }

    // MARK: Local

    private func localMatches(_ query: String, saved: [SavedPlace]) -> [SearchResult] {
        let q = Self.normalize(query)

        let savedHits = saved
            .filter { Self.normalize($0.name).contains(q) }
            .prefix(4)
            .map { place in
                SearchResult(id: "saved-\(place.id)",
                             title: place.name,
                             subtitle: "Saved · \(place.category.title)",
                             coordinate: place.coordinate,
                             kind: .saved,
                             symbol: place.category.symbol)
            }

        let townHits = KosovoGazetteer.towns
            .compactMap { town -> (KosovoTown, Bool)? in
                let names = town.names.map(Self.normalize)
                if names.contains(where: { $0.hasPrefix(q) }) { return (town, true) }
                if names.contains(where: { $0.contains(q) }) { return (town, false) }
                return nil
            }
            .sorted { $0.1 && !$1.1 }
            .prefix(6)
            .map { town, _ in
                SearchResult(id: "town-\(town.title)",
                             title: town.title,
                             subtitle: "\(town.title), Kosovo",
                             coordinate: town.coordinate,
                             kind: .city,
                             symbol: "building.2.fill")
            }

        return Array(savedHits) + Array(townHits)
    }

    private static func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
