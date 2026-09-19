import SwiftUI
import SwiftData

@main
struct KosovoMapApp: App {
    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    @State private var network = NetworkMonitor()
    @State private var location = LocationManager()
    @State private var mapManager = MapManager()
    @State private var search = SearchManager()

    private let container = StorageManager.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(network)
                .environment(location)
                .environment(mapManager)
                .environment(search)
                .modelContainer(container)
                .preferredColorScheme(appearance.colorScheme)
                .tint(Theme.cobalt)
        }
    }
}
