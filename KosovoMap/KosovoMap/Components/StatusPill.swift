import SwiftUI

/// Small connectivity indicator under the search bar. Tap opens Layers.
struct StatusPill: View {
    let mode: MapMode
    let effective: EffectiveMapMode
    let isConnected: Bool
    let action: () -> Void

    private var isOnline: Bool { effective == .online }
    private var noConnection: Bool { isOnline && !isConnected }

    private var text: String {
        if noConnection { return "No connection" }
        let base = isOnline ? "Online" : "Offline"
        return mode == .auto ? "\(base) · Auto" : base
    }

    private var tint: Color { (isOnline && !noConnection) ? Theme.online : Theme.offline }

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                Circle().fill(tint).frame(width: 8, height: 8)
                Text(text)
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .contentTransition(.opacity)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 40)
            .contentShape(Capsule())
        }
        .buttonStyle(PressScaleStyle())
        .glass(Capsule(), interactive: true)
        .animation(.snappy(duration: 0.25), value: text)
        .accessibilityLabel("Map status: \(text)")
        .accessibilityHint("Opens map layers and mode")
    }
}
