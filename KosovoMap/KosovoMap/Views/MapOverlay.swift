import SwiftUI
import CoreLocation
import MapLibre

/// Everything that floats above the map on the Map tab.
struct MapOverlay: View {
    let places: [SavedPlace]
    let effective: EffectiveMapMode
    let onSave: (DroppedPin) -> Void

    @Environment(NetworkMonitor.self) private var network
    @Environment(LocationManager.self) private var location
    @Environment(MapManager.self) private var mapManager
    @Environment(SearchManager.self) private var search
    @AppStorage("mapMode") private var mapMode: MapMode = .auto

    @State private var query = ""
    @FocusState private var searchFocused: Bool
    @State private var showLayers = false
    @State private var showLocationDenied = false

    var body: some View {
        ZStack {
            if searchFocused {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { searchFocused = false }
            }

            topLayer
            bottomLayer
        }
        .animation(.snappy(duration: 0.28), value: searchFocused)
        .sheet(isPresented: $showLayers) {
            LayersSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
        .alert("Location Is Off", isPresented: $showLocationDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("Turn on Location for KosovoMap in Settings to see where you are on the map.")
        }
        .onChange(of: query) { _, newValue in
            search.search(newValue, saved: places, allowNetwork: effective == .online)
        }
        .onChange(of: location.isAuthorized) { _, granted in
            if granted { mapManager.setTracking(.follow) }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.8))
            if location.authorization == .notDetermined { location.requestPermission() }
        }
    }

    // MARK: Top

    private var topLayer: some View {
        VStack(spacing: 12) {
            FloatingSearchBar(text: $query, focused: $searchFocused, isLoading: search.isLoading)

            if searchFocused {
                SearchResultsView(query: query, results: search.results, isLoading: search.isLoading) { result in
                    select(result)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                HStack(alignment: .top) {
                    StatusPill(mode: mapMode, effective: effective, isConnected: network.isOnline) {
                        showLayers = true
                    }
                    Spacer()
                    VStack(spacing: 12) {
                        RoundGlassButton(symbol: "square.3.layers.3d", label: "Layers") {
                            Haptics.tap()
                            showLayers = true
                        }
                        RoundGlassButton(symbol: locationSymbol,
                                         label: "My Location",
                                         isActive: mapManager.trackingMode != .none) {
                            locationTapped()
                        }
                    }
                }
                .transition(.opacity)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: Bottom

    private var bottomLayer: some View {
        VStack {
            Spacer()
            if let pin = mapManager.dropped, !searchFocused {
                DropCard(pin: pin,
                         onSave: { onSave(pin) },
                         onDismiss: { withAnimation(.snappy) { mapManager.clearPin() } })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 84)   // clear of the floating tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35), value: mapManager.dropped?.id)
    }

    // MARK: Actions

    private var locationSymbol: String {
        switch mapManager.trackingMode {
        case .follow: "location.fill"
        case .followWithHeading, .followWithCourse: "location.north.line.fill"
        default: "location"
        }
    }

    private func locationTapped() {
        Haptics.tap()
        if location.isDenied {
            showLocationDenied = true
        } else if location.authorization == .notDetermined {
            location.requestPermission()
        } else {
            mapManager.cycleTracking()
        }
    }

    private func select(_ result: SearchResult) {
        Haptics.tap()
        searchFocused = false
        query = ""
        search.clear()
        mapManager.fly(to: result.coordinate, zoom: result.kind == .city ? 12.5 : 16)
        if result.kind != .saved {
            withAnimation(.spring(duration: 0.35)) {
                mapManager.dropPin(at: result.coordinate, name: result.title)
            }
        }
    }
}
