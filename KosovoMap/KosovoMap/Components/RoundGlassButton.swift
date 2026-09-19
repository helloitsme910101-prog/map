import SwiftUI

struct RoundGlassButton: View {
    let symbol: String
    let label: String
    var isActive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(isActive ? Theme.cobalt : .primary)
                .frame(width: 52, height: 52)
                .contentTransition(.symbolEffect(.replace))
                .contentShape(Circle())
        }
        .buttonStyle(PressScaleStyle())
        .glass(Circle(), interactive: true)
        .accessibilityLabel(label)
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
