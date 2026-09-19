import SwiftUI

/// Liquid Glass on iOS 26+, translucent material with a hairline edge before that.
struct GlassSurface<S: InsettableShape>: ViewModifier {
    let shape: S
    var interactive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(interactive ? Glass.regular.interactive() : Glass.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.14), radius: 16, y: 6)
        }
    }
}

extension View {
    func glass<S: InsettableShape>(_ shape: S, interactive: Bool = false) -> some View {
        modifier(GlassSurface(shape: shape, interactive: interactive))
    }
}
