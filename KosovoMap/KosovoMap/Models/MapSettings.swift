import SwiftUI

/// What the person chose in Settings.
enum MapMode: String, CaseIterable, Identifiable {
    case online, offline, auto

    var id: String { rawValue }

    var title: String {
        switch self {
        case .online: "Online"
        case .offline: "Offline"
        case .auto: "Auto"
        }
    }

    var detail: String {
        switch self {
        case .online: "Uses internet data."
        case .offline: "Uses downloaded Kosovo map data."
        case .auto: "Switches automatically when your connection changes."
        }
    }

    var symbol: String {
        switch self {
        case .online: "wifi"
        case .offline: "wifi.slash"
        case .auto: "sparkles"
        }
    }

    func resolve(isOnline: Bool) -> EffectiveMapMode {
        switch self {
        case .online: .online
        case .offline: .offline
        case .auto: isOnline ? .online : .offline
        }
    }
}

/// What the app is actually doing right now.
enum EffectiveMapMode {
    case online, offline
}

enum MapStyleChoice: String, CaseIterable, Identifiable {
    case clean, detailed

    var id: String { rawValue }
    var title: String { self == .clean ? "Clean" : "Detailed" }
    var detail: String {
        self == .clean ? "Quiet roads and labels" : "Parks, buildings and places"
    }

    /// OpenFreeMap styles (OpenStreetMap data, no API key).
    func url(for scheme: ColorScheme) -> URL {
        let name: String
        switch (self, scheme) {
        case (.clean, .light): name = "positron"
        case (.clean, _): name = "dark"
        case (.detailed, .light): name = "liberty"
        case (.detailed, _): name = "fiord"
        }
        return URL(string: "https://tiles.openfreemap.org/styles/\(name)")!
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case map, places, history, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .map: "Map"
        case .places: "Places"
        case .history: "History"
        case .settings: "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .map: "map.fill"
        case .places: "mappin.and.ellipse"
        case .history: "clock.arrow.circlepath"
        case .settings: "gearshape.fill"
        }
    }
}
