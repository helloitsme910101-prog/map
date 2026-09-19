import CoreLocation

enum KosovoGeo {
    static let center = CLLocationCoordinate2D(latitude: 42.60, longitude: 20.90)
    static let initialZoom: Double = 7.6

    static let minLat = 41.85, maxLat = 43.27
    static let minLon = 19.97, maxLon = 21.80

    /// minLon,minLat,maxLon,maxLat
    static let bbox = "\(minLon),\(minLat),\(maxLon),\(maxLat)"

    /// The map can drift a little past the border but not leave the country's neighbourhood.
    static func containsPadded(_ c: CLLocationCoordinate2D, padding: Double = 0.45) -> Bool {
        c.latitude >= minLat - padding && c.latitude <= maxLat + padding &&
        c.longitude >= minLon - padding && c.longitude <= maxLon + padding
    }
}

/// Built-in gazetteer so the main towns are searchable with no connection.
/// Coordinates are approximate town centres. Full offline search arrives with the offline map (step 2).
struct KosovoTown {
    let names: [String]      // first entry is the display name
    let latitude: Double
    let longitude: Double

    var title: String { names[0] }
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}

enum KosovoGazetteer {
    static let towns: [KosovoTown] = [
        .init(names: ["Prishtina", "Prishtinë", "Priština", "Pristina"], latitude: 42.6629, longitude: 21.1655),
        .init(names: ["Prizren"], latitude: 42.2139, longitude: 20.7397),
        .init(names: ["Peja", "Pejë", "Peć", "Pec"], latitude: 42.6593, longitude: 20.2883),
        .init(names: ["Gjakova", "Gjakovë", "Đakovica", "Djakovica"], latitude: 42.3803, longitude: 20.4308),
        .init(names: ["Mitrovica", "Mitrovicë"], latitude: 42.8914, longitude: 20.8660),
        .init(names: ["Ferizaj", "Uroševac", "Urosevac"], latitude: 42.3702, longitude: 21.1553),
        .init(names: ["Gjilan", "Gnjilane"], latitude: 42.4635, longitude: 21.4694),
        .init(names: ["Vushtrri", "Vučitrn", "Vucitrn"], latitude: 42.8231, longitude: 20.9675),
        .init(names: ["Podujeva", "Podujevë", "Podujevo"], latitude: 42.9106, longitude: 21.1933),
        .init(names: ["Suhareka", "Suharekë", "Suva Reka"], latitude: 42.3589, longitude: 20.8250),
        .init(names: ["Rahovec", "Orahovac"], latitude: 42.3986, longitude: 20.6547),
        .init(names: ["Drenas", "Gllogoc", "Glogovac"], latitude: 42.6244, longitude: 20.8933),
        .init(names: ["Lipjan", "Lipljan"], latitude: 42.5219, longitude: 21.1256),
        .init(names: ["Malisheva", "Malishevë", "Mališevo"], latitude: 42.4822, longitude: 20.7458),
        .init(names: ["Kamenica", "Kamenicë"], latitude: 42.5783, longitude: 21.5806),
        .init(names: ["Deçan", "Dečani", "Decan"], latitude: 42.5400, longitude: 20.2900),
        .init(names: ["Istog", "Istok"], latitude: 42.7800, longitude: 20.4881),
        .init(names: ["Kaçanik", "Kačanik", "Kacanik"], latitude: 42.2317, longitude: 21.2603),
        .init(names: ["Shtime", "Štimlje"], latitude: 42.4333, longitude: 21.0400),
        .init(names: ["Skenderaj", "Srbica"], latitude: 42.7467, longitude: 20.7889),
        .init(names: ["Obiliq", "Obilić"], latitude: 42.6864, longitude: 21.0667),
        .init(names: ["Fushë Kosovë", "Kosovo Polje", "Fushe Kosove"], latitude: 42.6394, longitude: 21.0964),
        .init(names: ["Graçanicë", "Gračanica", "Gracanica"], latitude: 42.6008, longitude: 21.1911),
        .init(names: ["Viti", "Vitina"], latitude: 42.3192, longitude: 21.3597),
        .init(names: ["Dragash", "Dragaš"], latitude: 42.0625, longitude: 20.6533),
        .init(names: ["Klina", "Klinë"], latitude: 42.6217, longitude: 20.5764),
        .init(names: ["Han i Elezit", "Elez Han", "Hani i Elezit"], latitude: 42.1467, longitude: 21.2969),
        .init(names: ["Zveçan", "Zvečan"], latitude: 42.9076, longitude: 20.8391),
        .init(names: ["Leposaviq", "Leposavić"], latitude: 43.1017, longitude: 20.8025),
    ]

    static let featured: [KosovoTown] = Array(towns.prefix(6))
}
