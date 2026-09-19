import SwiftUI
import SwiftData
import CoreLocation

struct RootView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NetworkMonitor.self) private var network
    @Environment(LocationManager.self) private var location
    @Environment(MapManager.self) private var mapManager
    @Environment(SearchManager.self) private var search

    @Query(sort: \SavedPlace.date, order: .reverse) private var places: [SavedPlace]

    @AppStorage("mapMode") private var mapMode: MapMode = .auto
    @AppStorage("mapStyle") private var mapStyle: MapStyleChoice = .clean
    @AppStorage("show3D") private var show3D = false

    @State private var tab: AppTab = .map
    @State private var savingPin: DroppedPin?
    @State private var editingPlace: SavedPlace?

    private var effective: EffectiveMapMode { mapMode.resolve(isOnline: network.isOnline) }

    var body: some View {
        ZStack(alignment: .bottom) {
            // The map stays alive underneath every tab.
            MapLibreView(
                styleURL: mapStyle.url(for: scheme),
                places: places,
                dropped: mapManager.dropped,
                show3D: show3D,
                showsUserLocation: location.isAuthorized,
                mapManager: mapManager,
                onTap: handleMapTap,
                onSelectPlace: { id in editingPlace = places.first { $0.id == id } }
            )
            .ignoresSafeArea()

            Group {
                switch tab {
                case .map:
                    MapOverlay(places: places, effective: effective) { savingPin = $0 }
                case .places:
                    PlacesView(places: places, onOpen: openOnMap, onEdit: { editingPlace = $0 })
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .transition(.opacity)

            FloatingTabBar(selection: $tab)
        }
        .sheet(item: $savingPin) { pin in SavePlaceSheet(pin: pin) }
        .sheet(item: $editingPlace) { place in SavePlaceSheet(place: place) }
    }

    private func handleMapTap(_ coordinate: CLLocationCoordinate2D) {
        Haptics.tap()
        let pin = withAnimation(.spring(duration: 0.35)) { mapManager.dropPin(at: coordinate) }
        guard effective == .online else { return }
        Task {
            if let name = await search.reverse(coordinate), mapManager.dropped?.id == pin.id {
                mapManager.dropped?.name = name
            }
        }
    }

    private func openOnMap(_ place: SavedPlace) {
        withAnimation(.snappy(duration: 0.3)) { tab = .map }
        mapManager.fly(to: place.coordinate)
    }
}
