import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(LocationManager.self) private var location
    @Environment(MapManager.self) private var mapManager

    @AppStorage("mapMode") private var mapMode: MapMode = .auto
    @AppStorage("mapStyle") private var mapStyle: MapStyleChoice = .clean
    @AppStorage("show3D") private var show3D = false
    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    @State private var confirmDelete = false

    private var permissionText: String {
        switch location.authorization {
        case .authorizedAlways: "Always"
        case .authorizedWhenInUse: "While Using"
        case .denied: "Off"
        case .restricted: "Restricted"
        default: "Not Asked"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Map") {
                    NavigationLink {
                        ScrollView { MapModePicker(selection: $mapMode).padding(20) }
                            .background(Color(.systemGroupedBackground))
                            .navigationTitle("Map Mode")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        LabeledContent("Map Mode", value: mapMode.title)
                    }
                    Picker("Map Style", selection: $mapStyle) {
                        ForEach(MapStyleChoice.allCases) { Text($0.title).tag($0) }
                    }
                    Toggle("3D Buildings", isOn: $show3D)
                    LabeledContent("Traffic", value: "Not available")
                }

                Section("Location") {
                    LabeledContent("Permission", value: permissionText)
                    if location.isDenied {
                        Button("Open iPhone Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                        }
                    }
                    LabeledContent("Location Tracking", value: "Step 2")
                    LabeledContent("Background Tracking", value: "Step 2")
                }

                Section {
                    LabeledContent("Download Kosovo", value: "Step 2")
                    LabeledContent("Storage", value: "Step 2")
                } header: {
                    Text("Offline")
                } footer: {
                    Text("Until the offline map arrives, Offline mode stops online search. The map shows only what your iPhone has already cached.")
                }

                Section {
                    Button("Delete All My Data", role: .destructive) { confirmDelete = true }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Saved places, photos and settings live only on this iPhone. There is no account and no server. Map tiles and searches are requested from OpenFreeMap and Photon when you're online.")
                }

                Section("Appearance") {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppearanceMode.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section { EmptyView() } footer: {
                    Text("Map data © OpenStreetMap contributors. Tiles by OpenFreeMap.")
                }
            }
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 76) }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all your data?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    StorageManager.deleteAll(context: context)
                    mapManager.clearPin()
                    Haptics.warning()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Saved places, photos and settings will be permanently removed from this iPhone. This can't be undone.")
            }
        }
    }
}
