import Foundation
import CoreLocation
import MapLibre
import Observation

/// The single place that talks to the live MLNMapView.
@MainActor
@Observable
final class MapManager {
    @ObservationIgnored weak var mapView: MLNMapView?

    private(set) var trackingMode: MLNUserTrackingMode = .none
    var dropped: DroppedPin?

    func attach(_ view: MLNMapView) { mapView = view }

    func trackingChanged(_ mode: MLNUserTrackingMode) { trackingMode = mode }

    // MARK: Camera

    func fly(to coordinate: CLLocationCoordinate2D, zoom: Double = 15.5) {
        guard let mv = mapView else { return }
        if mv.userTrackingMode != .none { mv.userTrackingMode = .none }
        let altitude = MLNAltitudeForZoomLevel(zoom, mv.camera.pitch, coordinate.latitude, mv.bounds.size)
        let camera = MLNMapCamera(lookingAtCenter: coordinate,
                                  altitude: altitude,
                                  pitch: mv.camera.pitch,
                                  heading: 0)
        mv.fly(to: camera, withDuration: 1.1, completionHandler: nil)
    }

    /// none → follow → follow with heading → none
    func cycleTracking() {
        switch trackingMode {
        case .none: setTracking(.follow)
        case .follow: setTracking(.followWithHeading)
        default: setTracking(.none)
        }
    }

    func setTracking(_ mode: MLNUserTrackingMode) {
        guard let mv = mapView else { return }
        if mode != .none && !mv.showsUserLocation { mv.showsUserLocation = true }
        mv.setUserTrackingMode(mode, animated: true, completionHandler: nil)
        trackingMode = mode
    }

    // MARK: Dropped pin

    @discardableResult
    func dropPin(at coordinate: CLLocationCoordinate2D, name: String? = nil) -> DroppedPin {
        let pin = DroppedPin(coordinate: coordinate, name: name)
        dropped = pin
        return pin
    }

    func clearPin() { dropped = nil }
}
