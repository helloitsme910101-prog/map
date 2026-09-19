import SwiftUI
import MapLibre
import CoreLocation

/// Custom annotation that remembers which saved place it represents.
final class PlaceAnnotation: MLNPointAnnotation {
    var placeID: UUID?
    var category: PlaceCategory?
    var isDropped = false
}

struct MapLibreView: UIViewRepresentable {
    let styleURL: URL
    let places: [SavedPlace]
    let dropped: DroppedPin?
    let show3D: Bool
    let showsUserLocation: Bool
    let mapManager: MapManager
    let onTap: (CLLocationCoordinate2D) -> Void
    let onSelectPlace: (UUID) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> MLNMapView {
        let mv = MLNMapView(frame: .zero, styleURL: styleURL)
        mv.delegate = context.coordinator
        mv.setCenter(KosovoGeo.center, zoomLevel: KosovoGeo.initialZoom, animated: false)
        mv.minimumZoomLevel = 7
        mv.maximumZoomLevel = 19
        mv.showsUserHeadingIndicator = true

        // Keep MapLibre's required attribution, move ornaments clear of our floating UI.
        mv.logoView.isHidden = true
        mv.attributionButtonPosition = .bottomRight
        mv.attributionButtonMargins = CGPoint(x: 12, y: 84)
        mv.compassViewPosition = .topLeft
        mv.compassViewMargins = CGPoint(x: 12, y: 120)

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        for recognizer in mv.gestureRecognizers ?? [] where recognizer is UITapGestureRecognizer {
            tap.require(toFail: recognizer)
        }
        mv.addGestureRecognizer(tap)

        mapManager.attach(mv)
        return mv
    }

    func updateUIView(_ mv: MLNMapView, context: Context) {
        let c = context.coordinator
        c.parent = self

        if c.currentStyleURL != styleURL {
            c.currentStyleURL = styleURL
            mv.styleURL = styleURL
        }
        if mv.showsUserLocation != showsUserLocation {
            mv.showsUserLocation = showsUserLocation
        }
        c.syncAnnotations(in: mv)
        c.apply3D(show3D, in: mv)
    }

    // MARK: Coordinator

    @MainActor
    final class Coordinator: NSObject, MLNMapViewDelegate {
        var parent: MapLibreView
        var currentStyleURL: URL
        private var is3D = false
        private var placeAnnotations: [UUID: PlaceAnnotation] = [:]
        private var droppedAnnotation: PlaceAnnotation?

        init(parent: MapLibreView) {
            self.parent = parent
            self.currentStyleURL = parent.styleURL
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended, let mv = gesture.view as? MLNMapView else { return }
            let point = gesture.location(in: mv)
            parent.onTap(mv.convert(point, toCoordinateFrom: mv))
        }

        // MARK: Annotations

        func syncAnnotations(in mv: MLNMapView) {
            let ids = Set(parent.places.map(\.id))
            for (id, annotation) in placeAnnotations where !ids.contains(id) {
                mv.removeAnnotation(annotation)
                placeAnnotations[id] = nil
            }

            for place in parent.places {
                let coordinate = place.coordinate
                if let existing = placeAnnotations[place.id] {
                    let unchanged = existing.category == place.category
                        && existing.coordinate.latitude == coordinate.latitude
                        && existing.coordinate.longitude == coordinate.longitude
                    if unchanged {
                        if existing.title != place.name { existing.title = place.name }
                        continue
                    }
                    mv.removeAnnotation(existing)
                }
                let annotation = PlaceAnnotation()
                annotation.coordinate = coordinate
                annotation.title = place.name
                annotation.placeID = place.id
                annotation.category = place.category
                mv.addAnnotation(annotation)
                placeAnnotations[place.id] = annotation
            }

            if let pin = parent.dropped {
                if let current = droppedAnnotation,
                   current.coordinate.latitude == pin.coordinate.latitude,
                   current.coordinate.longitude == pin.coordinate.longitude {
                    // unchanged
                } else {
                    if let current = droppedAnnotation { mv.removeAnnotation(current) }
                    let annotation = PlaceAnnotation()
                    annotation.coordinate = pin.coordinate
                    annotation.isDropped = true
                    mv.addAnnotation(annotation)
                    droppedAnnotation = annotation
                }
            } else if let current = droppedAnnotation {
                mv.removeAnnotation(current)
                droppedAnnotation = nil
            }
        }

        // MARK: 3D buildings

        func apply3D(_ enabled: Bool, in mv: MLNMapView) {
            guard enabled != is3D else { return }
            is3D = enabled
            updateBuildingLayer(in: mv)
            let camera = mv.camera
            let target = MLNMapCamera(lookingAtCenter: camera.centerCoordinate,
                                      altitude: camera.altitude,
                                      pitch: enabled ? 55 : 0,
                                      heading: camera.heading)
            mv.setCamera(target, withDuration: 0.6,
                         animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut))
        }

        private func updateBuildingLayer(in mv: MLNMapView) {
            guard let style = mv.style else { return }
            if let existing = style.layer(withIdentifier: "kosovomap-3d") {
                existing.isVisible = is3D
                return
            }
            guard is3D, let source = style.source(withIdentifier: "openmaptiles") else { return }

            let layer = MLNFillExtrusionStyleLayer(identifier: "kosovomap-3d", source: source)
            layer.sourceLayerIdentifier = "building"
            layer.fillExtrusionHeight = NSExpression(forKeyPath: "render_height")
            layer.fillExtrusionBase = NSExpression(forKeyPath: "render_min_height")
            layer.fillExtrusionColor = NSExpression(forConstantValue: UIColor.systemGray3)
            layer.fillExtrusionOpacity = NSExpression(forConstantValue: 0.7)
            layer.minimumZoomLevel = 14

            if let firstLabels = style.layers.first(where: { $0 is MLNSymbolStyleLayer }) {
                style.insertLayer(layer, below: firstLabels)
            } else {
                style.addLayer(layer)
            }
        }

        // MARK: MLNMapViewDelegate

        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            updateBuildingLayer(in: mapView)
        }

        func mapView(_ mapView: MLNMapView, shouldChangeFrom oldCamera: MLNMapCamera, to newCamera: MLNMapCamera) -> Bool {
            KosovoGeo.containsPadded(newCamera.centerCoordinate)
        }

        func mapView(_ mapView: MLNMapView, didChange mode: MLNUserTrackingMode, animated: Bool) {
            parent.mapManager.trackingChanged(mode)
        }

        func mapView(_ mapView: MLNMapView, annotationCanShowCallout annotation: MLNAnnotation) -> Bool { false }

        func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
            guard let place = annotation as? PlaceAnnotation else { return nil }
            let key = place.isDropped ? "pin-dropped" : "pin-\(place.category?.rawValue ?? "other")"
            if let reused = mapView.dequeueReusableAnnotationImage(withIdentifier: key) { return reused }

            let image: UIImage
            if place.isDropped {
                image = MarkerRenderer.pin(color: UIColor(Theme.gold), symbol: "plus")
            } else {
                let category = place.category ?? .other
                image = MarkerRenderer.pin(color: category.uiColor, symbol: category.symbol)
            }
            return MLNAnnotationImage(image: image, reuseIdentifier: key)
        }

        func mapView(_ mapView: MLNMapView, didSelect annotation: MLNAnnotation) {
            defer { mapView.deselectAnnotation(annotation, animated: false) }
            guard let place = annotation as? PlaceAnnotation, let id = place.placeID else { return }
            parent.onSelectPlace(id)
        }
    }
}
